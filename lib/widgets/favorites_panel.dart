import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/favorites_provider.dart';
import '../providers/nickname_provider.dart';
import '../providers/selected_pokemon_provider.dart';
import '../screens/pokemon_detail_screen.dart';
import 'pixel_heart.dart';

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
          child: const PixelHeart(size: 26, color: Colors.white),
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
        Positioned.fill(
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
              children: [
                for (final panel in previous) Positioned.fill(child: panel),
                if (current != null) Positioned.fill(child: current),
              ],
            ),
            child: expanded
                ? _DraggablePanel(
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

class _DraggablePanel extends ConsumerStatefulWidget {
  const _DraggablePanel({super.key, required this.openDetailsOnTap});

  final bool openDetailsOnTap;

  @override
  ConsumerState<_DraggablePanel> createState() => _DraggablePanelState();
}

class _DraggablePanelState extends ConsumerState<_DraggablePanel> {
  static const double _peekHeight = 230;
  static const double _maxSize = 0.85;

  final DraggableScrollableController _sheet = DraggableScrollableController();
  bool _closing = false;

  @override
  void dispose() {
    _sheet.dispose();
    super.dispose();
  }

  void _collapse() {
    if (_closing) return;
    _closing = true;
    ref.read(favoritesPanelExpandedProvider.notifier).collapse();
  }

  void _toggleSize(double peekSize) {
    if (!_sheet.isAttached) return;
    final target = _sheet.size < _maxSize - 0.05 ? _maxSize : peekSize;
    _sheet.animateTo(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  bool _onSheetMoved(DraggableScrollableNotification notification) {
    if (notification.extent <= 0.05) _collapse();
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final peekSize =
            (_peekHeight / constraints.maxHeight).clamp(0.2, _maxSize);

        return NotificationListener<DraggableScrollableNotification>(
          onNotification: _onSheetMoved,
          child: DraggableScrollableSheet(
            controller: _sheet,
            initialChildSize: peekSize,
            minChildSize: 0,
            maxChildSize: _maxSize,
            snap: true,
            snapSizes: [peekSize],
            builder: (context, scrollController) => _PanelBody(
              scrollController: scrollController,
              openDetailsOnTap: widget.openDetailsOnTap,
              onHandleTap: () => _toggleSize(peekSize),
              onClose: _collapse,
            ),
          ),
        );
      },
    );
  }
}

class _PanelBody extends ConsumerWidget {
  const _PanelBody({
    required this.scrollController,
    required this.openDetailsOnTap,
    required this.onHandleTap,
    required this.onClose,
  });

  final ScrollController scrollController;
  final bool openDetailsOnTap;
  final VoidCallback onHandleTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final favorites = ref.watch(favoritesProvider).values.toList();

    return Material(
      color: theme.colorScheme.surface,
      elevation: 12,
      shadowColor: const Color(0x66000000),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      clipBehavior: Clip.antiAlias,
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: Column(
              children: [
                Semantics(
                  button: true,
                  label: 'Drag up to expand favorites',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: onHandleTap,
                    child: SizedBox(
                      width: double.infinity,
                      height: 24,
                      child: Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 4, 4),
                  child: Row(
                    children: [
                      const PixelHeart(size: 20),
                      const SizedBox(width: 10),
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
                        onPressed: onClose,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (favorites.isEmpty)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 4, 16, 24),
                child: Text(
                  'No favorites yet. Tap the heart on a Pokémon card to add one.',
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 24),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 110,
                  mainAxisExtent: 120,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => _FavoriteTile(
                    key: ValueKey(favorites[index].id),
                    pokemon: favorites[index],
                    openDetailsOnTap: openDetailsOnTap,
                  ),
                  childCount: favorites.length,
                ),
              ),
            ),
        ],
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
