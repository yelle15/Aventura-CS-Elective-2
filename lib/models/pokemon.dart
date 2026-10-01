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

  static String artworkUrlFor(int id) =>
      'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/'
      'pokemon/other/official-artwork/$id.png';

  static int _idFromUrl(String url) {
    final segments =
        Uri.parse(url).pathSegments.where((s) => s.isNotEmpty).toList();
    final id = segments.isEmpty ? null : int.tryParse(segments.last);
    if (id == null) {
      throw FormatException('Could not read a Pokémon ID from $url');
    }
    return id;
  }

  String get displayName => prettify(name);

  String get formattedId => '#${id.toString().padLeft(3, '0')}';
}

String prettify(String apiName) => apiName
    .split('-')
    .where((part) => part.isNotEmpty)
    .map((part) => part[0].toUpperCase() + part.substring(1))
    .join(' ');
