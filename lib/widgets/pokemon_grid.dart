import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import 'pokemon_card.dart';

class PokemonGrid extends StatelessWidget {
  const PokemonGrid({super.key, required this.pokemon, required this.service});

  final List<Pokemon> pokemon;
  final PokemonService service;

  @override
  Widget build(BuildContext context) {
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
        service: service,
      ),
    );
  }
}
