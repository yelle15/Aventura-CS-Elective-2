import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pokedex_provider.dart';
import 'pokemon_card.dart';

class PokemonGrid extends StatelessWidget {
  const PokemonGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final pokemon = context.watch<PokedexProvider>().visiblePokemon;

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 250 / 350,
      ),
      itemCount: pokemon.length,
      itemBuilder: (context, index) => PokemonCard(
        key: ValueKey(pokemon[index].id),
        pokemon: pokemon[index],
      ),
    );
  }
}
