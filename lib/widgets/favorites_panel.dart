import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/favorites_provider.dart';
import '../providers/nickname_provider.dart';
import '../providers/selected_pokemon_provider.dart';
import '../screens/pokemon_detail_screen.dart';

class FavoritesFab extends ConsumerWidget {
  const FavoritesFab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(favoritesProvider.select((f) => f.length));
    final expanded = ref.watch(favoritesPanelExpandedProvider);

    return AnimatedScale(
      scale: expanded ? 0 : 1,
      duration: const Duration(milliseconds: 200),
      child: FloatingActionButton(
        tooltip: 'Show favorites',
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        onPressed: () =>
            ref.read(favoritesPanelExpandedProvider.notifier).expand(),
        child: Badge(
          isLabelVisible: count > 0,
          label: Text('$count'),
          backgroundColor: const Color(0xFFFFCB05),
          textColor: const Color(0xFF1D2C5E),
          child: const Icon(Icons.favorite),
        ),
      ),
    );
  }
}

class FavoritesPanel extends ConsumerWidget {
  const FavoritesPanel({
    super.key,
    required this.openDetailsOnTap,
    required this.child,
  });

  final bool openDetailsOnTap;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final expanded = ref.watch(favoritesPanelExpandedProvider);

    return Stack(
      children: [
        Positioned.fill(child: child),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (panel, animation) => SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(animation),
              child: panel,
            ),
            layoutBuilder: (current, previous) => Stack(
              alignment: Alignment.bottomCenter,
              children: [...previous, ?current],
            ),
            child: expanded
                ? _PanelContent(
                    key: const ValueKey('favorites-panel'),
                    openDetailsOnTap: openDetailsOnTap,
                  )
                : const SizedBox.shrink(),
          ),
        ),
      ],
    );
  }
}

class _PanelContent extends ConsumerWidget {
  const _PanelContent({super.key, required this.openDetailsOnTap});

  final bool openDetailsOnTap;

  void _collapse(WidgetRef ref) =>
      ref.read(favoritesPanelExpandedProvider.notifier).collapse();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favorites = ref.watch(favoritesProvider).values.toList();

    return GestureDetector(
      onVerticalDragEnd: (details) {
        if ((details.primaryVelocity ?? 0) > 200) _collapse(ref);
      },
      child: Material(
        color: theme.colorScheme.surface,
        elevation: 12,
        shadowColor: const Color(0x66000000),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 4, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: GestureDetector(
                    onTap: () => _collapse(ref),
                    child: Container(
                      margin: const EdgeInsets.only(top: 10, bottom: 4),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.favorite,
                      color: Color(0xFFE53935),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Favorites (${favorites.length})',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Hide favorites',
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                      onPressed: () => _collapse(ref),
                    ),
                  ],
                ),
                if (favorites.isEmpty)
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 4, 12, 8),
                    child: Text(
                      'No favorites yet. Tap the heart on a Pokémon card to add one.',
                    ),
                  )
                else
                  SizedBox(
                    height: 116,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: favorites.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) => _FavoriteTile(
                        key: ValueKey(favorites[index].id),
                        pokemon: favorites[index],
                        openDetailsOnTap: openDetailsOnTap,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FavoriteTile extends ConsumerWidget {
  const _FavoriteTile({
    super.key,
    required this.pokemon,
    required this.openDetailsOnTap,
  });

  final Pokemon pokemon;
  final bool openDetailsOnTap;

  void _onTap(BuildContext context, WidgetRef ref) {
    if (openDetailsOnTap) {
      openPokemonDetails(context, ref, pokemon);
    } else {
      ref.read(selectedPokemonProvider.notifier).select(pokemon);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final nickname = ref.watch(
      nicknameProvider.select((nicknames) => nicknames[pokemon.id]),
    );
    final isSelected = ref.watch(
      selectedPokemonProvider.select((p) => p?.id == pokemon.id),
    );
    final highlight = !openDetailsOnTap && isSelected;

    return SizedBox(
      width: 92,
      child: Stack(
        children: [
          Positioned.fill(
            child: Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: highlight
                    ? BorderSide(color: theme.colorScheme.primary, width: 2)
                    : BorderSide.none,
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => _onTap(context, ref),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(6, 8, 6, 6),
                  child: Column(
                    children: [
                      SizedBox.square(
                        dimension: 56,
                        child: Image.network(
                          pokemon.imageUrl,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.catching_pokemon, size: 40),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        nickname ?? pokemon.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      Text(
                        nickname == null
                            ? pokemon.formattedId
                            : pokemon.displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: IconButton(
              tooltip: 'Remove from favorites',
              visualDensity: VisualDensity.compact,
              iconSize: 16,
              icon: const Icon(Icons.close_rounded),
              onPressed: () => ref
                  .read(favoritesProvider.notifier)
                  .removeFavorite(pokemon.id),
            ),
          ),
        ],
      ),
    );
  }
}
