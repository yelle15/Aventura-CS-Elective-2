import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';

class SelectedPokemonNotifier extends Notifier<Pokemon?> {
  @override
  Pokemon? build() => null;

  void select(Pokemon pokemon) => state = pokemon;
}

final selectedPokemonProvider =
    NotifierProvider<SelectedPokemonNotifier, Pokemon?>(
  SelectedPokemonNotifier.new,
);
