import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/filter_provider.dart';
import 'pokemon_card.dart';

class PokemonGrid extends ConsumerWidget {
  const PokemonGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemon = ref.watch(visiblePokemonProvider);

    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 88),
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
