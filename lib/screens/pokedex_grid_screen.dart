import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/pokedex_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
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
        actions: const [_RefreshButton(), _ThemeButton()],
        bottom: const _RefreshProgress(),
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: AppTheme.backgroundFor(brightness)),
        child: const _PokedexBody(),
      ),
    );
  }
}

class _RefreshButton extends StatelessWidget {
  const _RefreshButton();

  @override
  Widget build(BuildContext context) {
    final pokedex = context.watch<PokedexProvider>();
    final busy = pokedex.isLoading || pokedex.isRefreshing;

    return IconButton(
      tooltip: 'Refresh',
      icon: const Icon(Icons.refresh_rounded),
      onPressed: busy ? null : () => context.read<PokedexProvider>().fetchPokemon(),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  const _ThemeButton();

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;

    return IconButton(
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
      icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
      onPressed: () => context.read<ThemeProvider>().toggle(brightness),
    );
  }
}

class _RefreshProgress extends StatelessWidget implements PreferredSizeWidget {
  const _RefreshProgress();

  @override
  Size get preferredSize => const Size.fromHeight(3);

  @override
  Widget build(BuildContext context) {
    final isRefreshing = context.watch<PokedexProvider>().isRefreshing;
    return SizedBox(
      height: 3,
      child: isRefreshing ? const LinearProgressIndicator() : null,
    );
  }
}

class _PokedexBody extends StatelessWidget {
  const _PokedexBody();

  @override
  Widget build(BuildContext context) {
    final pokedex = context.watch<PokedexProvider>();

    switch (pokedex.status) {
      case PokedexStatus.loading:
        return const LoadingView();

      case PokedexStatus.error:
        return ErrorView(
          message: pokedex.errorMessage ??
              'Something unexpected happened. Please try again.',
          onRetry: () => context.read<PokedexProvider>().fetchPokemon(),
        );

      case PokedexStatus.success:
        if (pokedex.pokemon.isEmpty) {
          return EmptyView(
            onRetry: () => context.read<PokedexProvider>().fetchPokemon(),
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

class _Results extends StatelessWidget {
  const _Results();

  @override
  Widget build(BuildContext context) {
    final pokedex = context.watch<PokedexProvider>();

    if (pokedex.filter.needsDetails && pokedex.isLoadingDetails) {
      return const LoadingView(message: 'Loading Pokédex data...');
    }

    if (pokedex.visiblePokemon.isEmpty) {
      return NoMatchesView(
        onClear: () => context.read<PokedexProvider>().clearFilters(),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          context.read<PokedexProvider>().fetchPokemon(showLoading: false),
      child: const PokemonGrid(),
    );
  }
}
