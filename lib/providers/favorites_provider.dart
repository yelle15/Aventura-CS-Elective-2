import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';

class FavoritesNotifier extends Notifier<Map<int, Pokemon>> {
  @override
  Map<int, Pokemon> build() => const {};

  void addFavorite(Pokemon pokemon) {
    if (state.containsKey(pokemon.id)) return;
    state = {...state, pokemon.id: pokemon};
  }

  void removeFavorite(int pokemonId) {
    if (!state.containsKey(pokemonId)) return;
    state = Map.of(state)..remove(pokemonId);
  }

  void toggleFavorite(Pokemon pokemon) {
    if (state.containsKey(pokemon.id)) {
      removeFavorite(pokemon.id);
    } else {
      addFavorite(pokemon);
    }
  }
}

final favoritesProvider =
    NotifierProvider<FavoritesNotifier, Map<int, Pokemon>>(
  FavoritesNotifier.new,
);

class FavoritesPanelNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() => state = !state;

  void expand() => state = true;

  void collapse() => state = false;
}

final favoritesPanelExpandedProvider =
    NotifierProvider<FavoritesPanelNotifier, bool>(FavoritesPanelNotifier.new);
