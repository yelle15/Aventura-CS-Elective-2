import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import 'pokemon_card.dart';

/// Scrollable grid of [PokemonCard]s. The column count adapts to the
/// screen width (about 2 on a phone, more on a tablet or the web).
class PokemonGrid extends StatelessWidget {
  const PokemonGrid({super.key, required this.pokemon, required this.service});

  final List<Pokemon> pokemon;
  final PokemonService service;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      // Always scrollable so pull-to-refresh works even with few items.
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 260,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 250 / 350, // same shape as a real card
      ),
      itemCount: pokemon.length,
      itemBuilder: (context, index) => PokemonCard(
        // Keyed by ID so each card keeps its loaded data while filtering.
        key: ValueKey(pokemon[index].id),
        pokemon: pokemon[index],
        service: service,
      ),
    );
  }
}
