import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/filter_provider.dart';
import '../providers/pokemon_details_provider.dart';
import '../providers/pokemon_list_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar_actions.dart';
import '../widgets/favorites_panel.dart';
import '../widgets/pokemon_grid.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/state_views.dart';

class PokedexGridScreen extends StatelessWidget {
  const PokedexGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 72,
        title: Image.asset(
          'assets/images/pokedex_logo.png',
          height: 52,
          fit: BoxFit.contain,
          semanticLabel: 'Pokédex',
          errorBuilder: (context, error, stackTrace) => const Text('Pokédex'),
        ),
        actions: const [
          _RefreshButton(),
          ThemeButton(),
        ],
        bottom: const _RefreshProgress(),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: AppTheme.backgroundFor(brightness)),
        child: const FavoritesPanel(
          openDetailsOnTap: true,
          child: _PokedexBody(),
        ),
      ),
      floatingActionButton: const FavoritesFab(),
    );
  }
}

class _RefreshButton extends ConsumerWidget {
  const _RefreshButton();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final busy = ref.watch(
      pokemonListProvider.select((s) => s.isLoading || s.isRefreshing),
    );

    return IconButton(
      tooltip: 'Refresh',
      icon: const Icon(Icons.refresh_rounded),
      onPressed: busy
          ? null
          : () => ref.read(pokemonListProvider.notifier).fetchPokemon(),
    );
  }
}

class _RefreshProgress extends ConsumerWidget implements PreferredSizeWidget {
  const _RefreshProgress();

  @override
  Size get preferredSize => const Size.fromHeight(3);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRefreshing =
        ref.watch(pokemonListProvider.select((s) => s.isRefreshing));
    return SizedBox(
      height: 3,
      child: isRefreshing ? const LinearProgressIndicator() : null,
    );
  }
}

class _PokedexBody extends ConsumerWidget {
  const _PokedexBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(pokemonListProvider);

    switch (list.status) {
      case PokedexStatus.loading:
        return const LoadingView();

      case PokedexStatus.error:
        return ErrorView(
          message: list.errorMessage ??
              'Something unexpected happened. Please try again.',
          onRetry: () => ref.read(pokemonListProvider.notifier).fetchPokemon(),
        );

      case PokedexStatus.success:
        if (list.pokemon.isEmpty) {
          return EmptyView(
            onRetry: () =>
                ref.read(pokemonListProvider.notifier).fetchPokemon(),
          );
        }
        return const Column(
          children: [
            SearchFilterBar(),
            Expanded(child: _Results()),
          ],
        );
    }
  }
}

class _Results extends ConsumerWidget {
  const _Results();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final needsDetails = ref.watch(filterProvider.select((f) => f.needsDetails));
    final detailsLoading =
        ref.watch(pokemonDetailsProvider.select((s) => s.isLoading));
    final visible = ref.watch(visiblePokemonProvider);

    if (needsDetails && detailsLoading) {
      return const LoadingView(message: 'Loading Pokémon types...');
    }

    if (visible.isEmpty) {
      return NoMatchesView(
        onClear: () => ref.read(filterProvider.notifier).clearAll(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(pokemonListProvider.notifier)
          .fetchPokemon(showLoading: false),
      child: const PokemonGrid(),
    );
  }
}
