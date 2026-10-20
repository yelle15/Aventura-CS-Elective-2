import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/favorites_provider.dart';

class FavoriteHeart extends ConsumerWidget {
  const FavoriteHeart({super.key, required this.pokemon, this.size = 22});

  final Pokemon pokemon;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(
      favoritesProvider.select((favorites) => favorites.containsKey(pokemon.id)),
    );
    final label = isFavorite ? 'Remove from favorites' : 'Add to favorites';

    return Tooltip(
      message: label,
      child: Semantics(
        button: true,
        toggled: isFavorite,
        label: label,
        child: Material(
          color: const Color(0xE6FFFFFF),
          shape: const CircleBorder(),
          elevation: 1,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: () =>
                ref.read(favoritesProvider.notifier).toggleFavorite(pokemon),
            child: Padding(
              padding: EdgeInsets.all(size * 0.22),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(isFavorite),
                  size: size,
                  color: isFavorite
                      ? const Color(0xFFE53935)
                      : const Color(0xFF616161),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
