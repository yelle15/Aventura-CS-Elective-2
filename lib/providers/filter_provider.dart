import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../models/pokemon_filter.dart';
import 'pokemon_details_provider.dart';
import 'pokemon_list_provider.dart';

class FilterNotifier extends Notifier<PokemonFilter> {
  @override
  PokemonFilter build() => const PokemonFilter();

  void setFilter(PokemonFilter filter) => state = filter;

  void setQuery(String query) => state = state.copyWith(query: query);

  void selectType(String? type) => state = state.copyWith(type: type);

  void clearType() => state = state.copyWith(type: null);

  void clearAll() => state = const PokemonFilter();
}

final filterProvider = NotifierProvider<FilterNotifier, PokemonFilter>(
  FilterNotifier.new,
);

class FilterDraftNotifier extends Notifier<PokemonFilter> {
  @override
  PokemonFilter build() => const PokemonFilter();

  void start() => state = ref.read(filterProvider);

  void edit(PokemonFilter Function(PokemonFilter draft) change) =>
      state = change(state);

  void apply() => ref.read(filterProvider.notifier).setFilter(state);
}

final filterDraftProvider =
    NotifierProvider<FilterDraftNotifier, PokemonFilter>(
  FilterDraftNotifier.new,
);

final visiblePokemonProvider = Provider<List<Pokemon>>((ref) {
  final pokemon = ref.watch(pokemonListProvider.select((s) => s.pokemon));
  final filter = ref.watch(filterProvider);
  final details = ref.watch(pokemonDetailsProvider.select((s) => s.loaded));

  return pokemon.where((p) => filter.matches(p, details[p.id])).toList();
});
