/// A single Pokémon as shown in the Pokédex grid.
///
/// The list endpoint (`/api/v2/pokemon`) only gives us a `name` and a `url`
/// for each Pokémon. The ID is the last part of that URL, and the artwork
/// URL can be built from the ID, so one request is enough for the whole grid.
class Pokemon {
  const Pokemon({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  final int id;
  final String name;
  final String imageUrl;

  factory Pokemon.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final url = json['url'];

    if (name is! String || url is! String) {
      throw const FormatException('Unexpected Pokémon entry format.');
    }

    final id = _idFromUrl(url);
    return Pokemon(id: id, name: name, imageUrl: artworkUrlFor(id));
  }

  /// Official artwork hosted in the PokéAPI sprites repository.
  static String artworkUrlFor(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/'
      'pokemon/other/official-artwork/$id.png';

  /// "https://pokeapi.co/api/v2/pokemon/25/" -> 25
  static int _idFromUrl(String url) {
    final segments =
        Uri.parse(url).pathSegments.where((s) => s.isNotEmpty).toList();
    final id = segments.isEmpty ? null : int.tryParse(segments.last);
    if (id == null) {
      throw FormatException('Could not read a Pokémon ID from $url');
    }
    return id;
  }

  /// "nidoran-f" -> "Nidoran F"
  String get displayName => prettify(name);

  /// 7 -> "#007"
  String get formattedId => '#${id.toString().padLeft(3, '0')}';
}

/// API names to display text: "thunder-shock" -> "Thunder Shock".
String prettify(String apiName) => apiName
    .split('-')
    .where((part) => part.isNotEmpty)
    .map((part) => part[0].toUpperCase() + part.substring(1))
    .join(' ');
