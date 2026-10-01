import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/pokemon.dart';
import '../models/pokemon_details.dart';

/// Error with a message that is safe to show on screen.
class PokemonServiceException implements Exception {
  const PokemonServiceException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Handles all calls to the PokéAPI.
///
/// Everything here returns a [Future] rather than a [Stream]. Each request
/// is made once and comes back as one complete response. Nothing about it
/// changes over time, so there is exactly one result per request.
class PokemonService {
  PokemonService({http.Client? client}) : _client = client ?? http.Client();

  static const String _apiRoot = 'https://pokeapi.co/api/v2';
  static const Duration _timeout = Duration(seconds: 10);

  final http.Client _client;

  // Caches hold the Future itself, so two cards asking for the same move
  // (e.g. Tackle) share one request instead of firing two.
  final Map<int, Future<PokemonDetails>> _detailsCache = {};
  final Map<String, Future<TypeMatchups>> _typeCache = {};
  final Map<String, Future<PokemonAttack>> _moveCache = {};
  final Map<String, Future<List<List<String>>>> _chainCache = {};

  // ---------------------------------------------------------------- list

  Future<List<Pokemon>> fetchPokemon({int limit = 30}) async {
    final uri = Uri.parse('$_apiRoot/pokemon').replace(
      queryParameters: {'limit': '$limit', 'offset': '0'},
    );

    final body = await _getJson(uri);
    final results = body['results'];
    if (results is! List) {
      throw const PokemonServiceException(
        'The PokéAPI sent data in an unexpected format.',
      );
    }

    try {
      return results
          .whereType<Map<String, dynamic>>()
          .map(Pokemon.fromJson)
          .toList();
    } on FormatException {
      throw const PokemonServiceException(
        'The PokéAPI sent data in an unexpected format.',
      );
    }
  }

  // ------------------------------------------------------------- details

  /// Card details for one Pokémon. Cached, so calling it again for the same
  /// ID returns the same Future. Failed requests are dropped from the
  /// cache, so "Retry" can try again.
  Future<PokemonDetails> fetchDetails(int id) {
    return _cached(_detailsCache, id, () => _loadDetails(id));
  }

  /// Returns the cached Future for [key], or starts [load] and caches it.
  /// A Future that fails is removed, so the next call tries again.
  static Future<T> _cached<K, T>(
    Map<K, Future<T>> cache,
    K key,
    Future<T> Function() load,
  ) {
    return cache.putIfAbsent(key, () {
      final future = load();
      future.then<void>((_) {}, onError: (Object _) => cache.remove(key));
      return future;
    });
  }

  Future<PokemonDetails> _loadDetails(int id) async {
    // Independent requests run at the same time (Future.wait),
    // not one after another.
    final responses = await Future.wait([
      _getJson(Uri.parse('$_apiRoot/pokemon/$id')),
      _getJson(Uri.parse('$_apiRoot/pokemon-species/$id')),
    ]);
    final pokemonJson = responses[0];
    final speciesJson = responses[1];

    try {
      final types = [
        for (final t in pokemonJson['types'] as List)
          t['type']['name'] as String,
      ];
      final stats = [
        for (final s in pokemonJson['stats'] as List)
          PokemonStat(
            name: s['stat']['name'] as String,
            value: s['base_stat'] as int,
          ),
      ];
      final abilities = [
        for (final a in pokemonJson['abilities'] as List)
          PokemonAbility(
            name: a['ability']['name'] as String,
            isHidden: a['is_hidden'] as bool,
          ),
      ];
      final candidates = _candidateMoves(pokemonJson['moves'] as List);
      final speciesName = speciesJson['name'] as String;
      final chainUrl = speciesJson['evolution_chain']?['url'] as String?;

      // These depend on the types, moves and species above, so they wait
      // for the first round. They are independent of each other, though.
      final second = await Future.wait<Object>([
        _fetchTypeMatchups(types.first),
        Future.wait(candidates.map(_fetchMove)),
        chainUrl == null
            ? Future.value(<List<String>>[[speciesName]])
            : _fetchEvolutionChain(chainUrl),
      ]);
      final matchups = second[0] as TypeMatchups;
      final moves = second[1] as List<PokemonAttack>;
      final evolutionStages = second[2] as List<List<String>>;

      final depth =
          evolutionStages.indexWhere((stage) => stage.contains(speciesName));

      return PokemonDetails(
        hp: stats.firstWhere((s) => s.name == 'hp').value,
        types: types,
        stage: switch (depth) {
          1 => 'STAGE 1',
          >= 2 => 'STAGE 2',
          _ => 'BASIC',
        },
        genus: _english(speciesJson['genera'] as List, 'genus') ?? 'Pokémon',
        heightM: (pokemonJson['height'] as int) / 10,
        weightKg: (pokemonJson['weight'] as int) / 10,
        colorName: speciesJson['color']['name'] as String,
        flavorText: _cleanText(
          _english(speciesJson['flavor_text_entries'] as List, 'flavor_text') ??
              '',
        ),
        attacks: _chooseAttacks(moves),
        abilities: abilities,
        stats: stats,
        habitat: speciesJson['habitat']?['name'] as String?,
        generation: _generationNumber(
          speciesJson['generation']['name'] as String,
        ),
        isLegendary: speciesJson['is_legendary'] as bool,
        isMythical: speciesJson['is_mythical'] as bool,
        evolutionStages: evolutionStages,
        weakness: matchups.weakness,
        resistance: matchups.resistance,
      );
    } on TypeError {
      throw const PokemonServiceException(
        'The PokéAPI sent card data in an unexpected format.',
      );
    }
  }

  /// Every Pokémon in one line shares the same chain, so it is cached by URL.
  Future<List<List<String>>> _fetchEvolutionChain(String url) {
    return _cached(_chainCache, url, () async {
      final json = await _getJson(Uri.parse(url));
      final stages = <List<String>>[];

      void walk(Map<String, dynamic> node, int depth) {
        if (stages.length <= depth) stages.add([]);
        stages[depth].add(node['species']['name'] as String);
        for (final next in node['evolves_to'] as List) {
          walk(next as Map<String, dynamic>, depth + 1);
        }
      }

      walk(json['chain'] as Map<String, dynamic>, 0);
      return stages;
    });
  }

  /// "generation-iv" -> 4
  static int _generationNumber(String name) {
    const roman = ['i', 'ii', 'iii', 'iv', 'v', 'vi', 'vii', 'viii', 'ix'];
    return roman.indexOf(name.split('-').last) + 1;
  }

  Future<TypeMatchups> _fetchTypeMatchups(String type) {
    return _cached(_typeCache, type, () async {
      final json = await _getJson(Uri.parse('$_apiRoot/type/$type'));
      final relations = json['damage_relations'] as Map<String, dynamic>;
      String? firstName(String key) {
        final list = relations[key] as List;
        return list.isEmpty ? null : list.first['name'] as String;
      }

      return TypeMatchups(
        weakness: firstName('double_damage_from'),
        resistance: firstName('half_damage_from'),
      );
    });
  }

  Future<PokemonAttack> _fetchMove(String name) {
    return _cached(_moveCache, name, () async {
      final json = await _getJson(Uri.parse('$_apiRoot/move/$name'));
      final chance = json['effect_chance'];
      final effect = _english(json['effect_entries'] as List, 'short_effect') ??
          'No additional effect.';

      return PokemonAttack(
        name: name,
        type: json['type']['name'] as String,
        power: json['power'] as int?,
        effect: _cleanText(effect.replaceAll(r'$effect_chance', '$chance')),
      );
    });
  }

  /// Up to 6 level-up moves spread from early to late, so the card can
  /// pick a weak opening attack and a stronger one.
  static List<String> _candidateMoves(List moves) {
    final levels = <String, int>{};
    for (final m in moves) {
      final name = m['move']['name'] as String;
      for (final d in m['version_group_details'] as List) {
        if (d['move_learn_method']['name'] != 'level-up') continue;
        final level = d['level_learned_at'] as int;
        final current = levels[name];
        if (current == null || level < current) levels[name] = level;
      }
    }

    final sorted = levels.keys.toList()
      ..sort((a, b) => levels[a]!.compareTo(levels[b]!));
    if (sorted.length <= 6) return sorted;

    final step = (sorted.length - 1) / 5;
    return {for (var i = 0; i < 6; i++) sorted[(i * step).round()]}.toList();
  }

  /// Like a real card: the weakest damaging move first, the strongest
  /// second. Status moves are only used if there aren't enough damaging ones.
  static List<PokemonAttack> _chooseAttacks(List<PokemonAttack> moves) {
    final damaging = moves.where((m) => (m.power ?? 0) > 0).toList()
      ..sort((a, b) => a.power!.compareTo(b.power!));

    final chosen = <PokemonAttack>[];
    if (damaging.isNotEmpty) chosen.add(damaging.first);
    if (damaging.length > 1) chosen.add(damaging.last);
    for (final m in moves) {
      if (chosen.length >= 2) break;
      if (!chosen.contains(m)) chosen.add(m);
    }
    return chosen;
  }

  static String? _english(List entries, String field) {
    for (final e in entries) {
      if (e['language']['name'] == 'en') return e[field] as String;
    }
    return null;
  }

  /// Pokédex text has line breaks and form-feeds from the games.
  static String _cleanText(String text) =>
      text.replaceAll(RegExp(r'[\n\f\r]+'), ' ').replaceAll('  ', ' ').trim();

  // ------------------------------------------------------------ helpers

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(_timeout);

      if (response.statusCode != 200) {
        throw PokemonServiceException(
          'The PokéAPI returned an error (HTTP ${response.statusCode}).',
        );
      }

      final body = jsonDecode(utf8.decode(response.bodyBytes));
      if (body is! Map<String, dynamic>) {
        throw const FormatException('Expected a JSON object.');
      }
      return body;
    } on TimeoutException {
      throw const PokemonServiceException(
        'The request took too long. Check your connection and try again.',
      );
    } on http.ClientException {
      throw const PokemonServiceException(
        'Could not reach the PokéAPI. Check your internet connection.',
      );
    } on FormatException {
      throw const PokemonServiceException(
        'The PokéAPI sent data in an unexpected format.',
      );
    }
  }

  /// Closes the underlying HTTP client. Call this from `dispose()`.
  void dispose() => _client.close();
}
