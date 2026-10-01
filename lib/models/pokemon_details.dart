import 'pokemon.dart';

/// Extra data for the trading card (front and back) of one Pokémon.
///
/// Comes from these PokéAPI endpoints:
/// - /pokemon/{id}          -> HP, stats, types, abilities, height, weight
/// - /pokemon-species/{id}  -> card color, category, habitat, generation,
///                             legendary/mythical, Pokédex entry
/// - /evolution-chain/{id}  -> evolution chain and stage
/// - /type/{name}           -> weakness and resistance
/// - /move/{name}           -> attack power, type, and effect text
class PokemonDetails {
  const PokemonDetails({
    required this.hp,
    required this.types,
    required this.stage,
    required this.genus,
    required this.heightM,
    required this.weightKg,
    required this.colorName,
    required this.flavorText,
    required this.attacks,
    required this.abilities,
    required this.stats,
    required this.habitat,
    required this.generation,
    required this.isLegendary,
    required this.isMythical,
    required this.evolutionStages,
    this.weakness,
    this.resistance,
  });

  /// Base HP stat from the games (the API has no TCG card data).
  final int hp;

  /// e.g. ['grass', 'poison']. The first one is the main type.
  final List<String> types;

  /// 'BASIC', 'STAGE 1' or 'STAGE 2'.
  final String stage;

  /// e.g. 'Mouse Pokémon'
  final String genus;
  final double heightM;
  final double weightKg;

  /// The species color from the API: yellow, red, blue, green, ...
  final String colorName;
  final String flavorText;
  final List<PokemonAttack> attacks;
  final List<PokemonAbility> abilities;
  final List<PokemonStat> stats;

  /// e.g. 'grassland'. Null for Pokémon the API has no habitat for.
  final String? habitat;

  /// 1 for Generation I, 2 for Generation II, ...
  final int generation;
  final bool isLegendary;
  final bool isMythical;

  /// Species names per evolution stage, e.g.
  /// [['bulbasaur'], ['ivysaur'], ['venusaur']].
  /// A stage can have more than one entry when the line branches.
  final List<List<String>> evolutionStages;

  final String? weakness;
  final String? resistance;

  String get mainType => types.first;

  String get generationLabel => generationLabelFor(generation);

  /// 1 -> "Gen I"
  static String generationLabelFor(int generation) {
    const roman = ['I', 'II', 'III', 'IV', 'V', 'VI', 'VII', 'VIII', 'IX'];
    return generation >= 1 && generation <= roman.length
        ? 'Gen ${roman[generation - 1]}'
        : 'Gen $generation';
  }
}

class PokemonAttack {
  const PokemonAttack({
    required this.name,
    required this.type,
    required this.power,
    required this.effect,
  });

  final String name;
  final String type;

  /// null for status moves (e.g. Growl), which deal no damage.
  final int? power;
  final String effect;

  /// How many energy symbols to show, scaled from the move's power.
  int get energyCost {
    final p = power;
    if (p == null || p <= 40) return 1;
    if (p <= 80) return 2;
    return 3;
  }

  String get displayName => prettify(name);
}

class PokemonAbility {
  const PokemonAbility({required this.name, required this.isHidden});

  final String name;
  final bool isHidden;

  String get displayName => prettify(name);
}

class PokemonStat {
  const PokemonStat({required this.name, required this.value});

  final String name;
  final int value;

  String get shortLabel => switch (name) {
        'hp' => 'HP',
        'attack' => 'ATK',
        'defense' => 'DEF',
        'special-attack' => 'SP.ATK',
        'special-defense' => 'SP.DEF',
        'speed' => 'SPD',
        _ => prettify(name),
      };
}

class TypeMatchups {
  const TypeMatchups({this.weakness, this.resistance});

  final String? weakness;
  final String? resistance;
}
