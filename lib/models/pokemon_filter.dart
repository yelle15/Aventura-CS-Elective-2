import 'pokemon.dart';
import 'pokemon_details.dart';

enum Rarity { any, legendary, mythical, regular }

/// Everything the user picked in the search bar, type chips and filter sheet.
class PokemonFilter {
  const PokemonFilter({
    this.query = '',
    this.type,
    this.generation,
    this.stage,
    this.minHeight,
    this.maxHeight,
    this.minWeight,
    this.maxWeight,
    this.rarity = Rarity.any,
    this.ability,
  });

  final String query;
  final String? type;
  final int? generation;
  final String? stage;
  final double? minHeight;
  final double? maxHeight;
  final double? minWeight;
  final double? maxWeight;
  final Rarity rarity;
  final String? ability;

  /// Name/number search works with just the list. Every other filter
  /// needs each Pokémon's details to be loaded first.
  bool get needsDetails =>
      type != null ||
      generation != null ||
      stage != null ||
      minHeight != null ||
      maxHeight != null ||
      minWeight != null ||
      maxWeight != null ||
      rarity != Rarity.any ||
      ability != null;

  /// Number of filters set in the filter sheet (for the badge).
  int get sheetFilterCount => [
        generation != null,
        stage != null,
        minHeight != null || maxHeight != null,
        minWeight != null || maxWeight != null,
        rarity != Rarity.any,
        ability != null,
      ].where((isSet) => isSet).length;

  bool get isEmpty => query.trim().isEmpty && !needsDetails;

  bool matches(Pokemon pokemon, PokemonDetails? details) {
    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      final number = int.tryParse(q.replaceAll('#', ''));
      final byName = pokemon.name.contains(q) ||
          pokemon.displayName.toLowerCase().contains(q);
      if (!byName && number != pokemon.id) return false;
    }

    if (!needsDetails) return true;
    final d = details;
    if (d == null) return false;

    if (type != null && !d.types.contains(type)) return false;
    if (generation != null && d.generation != generation) return false;
    if (stage != null && d.stage != stage) return false;
    if (minHeight != null && d.heightM < minHeight!) return false;
    if (maxHeight != null && d.heightM > maxHeight!) return false;
    if (minWeight != null && d.weightKg < minWeight!) return false;
    if (maxWeight != null && d.weightKg > maxWeight!) return false;
    if (ability != null && !d.abilities.any((a) => a.name == ability)) {
      return false;
    }

    return switch (rarity) {
      Rarity.any => true,
      Rarity.legendary => d.isLegendary,
      Rarity.mythical => d.isMythical,
      Rarity.regular => !d.isLegendary && !d.isMythical,
    };
  }

  static const Object _unset = Object();

  /// Pass `null` to clear a filter, leave it out to keep it.
  PokemonFilter copyWith({
    String? query,
    Object? type = _unset,
    Object? generation = _unset,
    Object? stage = _unset,
    Object? minHeight = _unset,
    Object? maxHeight = _unset,
    Object? minWeight = _unset,
    Object? maxWeight = _unset,
    Rarity? rarity,
    Object? ability = _unset,
  }) {
    T pick<T>(Object? value, T current) =>
        identical(value, _unset) ? current : value as T;

    return PokemonFilter(
      query: query ?? this.query,
      type: pick<String?>(type, this.type),
      generation: pick<int?>(generation, this.generation),
      stage: pick<String?>(stage, this.stage),
      minHeight: pick<double?>(minHeight, this.minHeight),
      maxHeight: pick<double?>(maxHeight, this.maxHeight),
      minWeight: pick<double?>(minWeight, this.minWeight),
      maxWeight: pick<double?>(maxWeight, this.maxWeight),
      rarity: rarity ?? this.rarity,
      ability: pick<String?>(ability, this.ability),
    );
  }

  /// Keeps the search text and type chip, clears the sheet filters.
  PokemonFilter clearSheetFilters() => PokemonFilter(query: query, type: type);
}
