import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../models/pokemon_details.dart';
import '../models/pokemon_filter.dart';
import '../services/pokemon_service.dart';
import '../theme/app_theme.dart';
import '../widgets/filter_sheet.dart';
import '../widgets/pokemon_grid.dart';
import '../widgets/search_filter_bar.dart';
import '../widgets/state_views.dart';

class PokedexScreen extends StatefulWidget {
  const PokedexScreen({super.key, this.service, this.onToggleTheme});

  /// Optional, so tests can pass in a service with a fake HTTP client.
  final PokemonService? service;

  /// Switches light/dark. Given the brightness currently on screen.
  final void Function(Brightness current)? onToggleTheme;

  @override
  State<PokedexScreen> createState() => _PokedexScreenState();
}

class _PokedexScreenState extends State<PokedexScreen> {
  static const int _limit = 30;

  late final PokemonService _service;
  late final bool _ownsService;
  final TextEditingController _searchController = TextEditingController();

  // Created in initState, NOT in build(). If it were created in build(),
  // every rebuild would fire a new request and the grid would flash back
  // to the loading spinner. Not `final`, because "Try again" replaces it.
  late Future<List<Pokemon>> _pokemonFuture;

  /// Details for every Pokémon, needed by the type chips and filter sheet.
  /// Only started the first time a filter needs it, then reused.
  Future<Map<int, PokemonDetails?>>? _allDetailsFuture;

  PokemonFilter _filter = const PokemonFilter();

  @override
  void initState() {
    super.initState();
    _ownsService = widget.service == null;
    _service = widget.service ?? PokemonService();
    _pokemonFuture = _service.fetchPokemon(limit: _limit);
  }

  @override
  void dispose() {
    _searchController.dispose();
    if (_ownsService) _service.dispose();
    super.dispose();
  }

  /// Used by the "Try again" button and by pull-to-refresh.
  Future<void> _reload() async {
    final future = _service.fetchPokemon(limit: _limit);
    setState(() {
      _pokemonFuture = future;
      _allDetailsFuture = null;
    });
    try {
      await future;
    } catch (_) {
      // The FutureBuilder below already shows the error.
    }
  }

  /// Loads every Pokémon's details at once. The service caches them, so
  /// cards that already loaded don't cause a second request. A Pokémon
  /// whose details fail is kept as null instead of failing the whole map.
  Future<Map<int, PokemonDetails?>> _allDetails(List<Pokemon> pokemon) {
    return _allDetailsFuture ??= () async {
      final results = await Future.wait(
        pokemon.map(
          (p) => _service.fetchDetails(p.id).then<PokemonDetails?>(
                (details) => details,
                onError: (Object _) => null,
              ),
        ),
      );
      return {
        for (var i = 0; i < pokemon.length; i++) pokemon[i].id: results[i],
      };
    }();
  }

  void _setFilter(PokemonFilter filter) => setState(() => _filter = filter);

  void _clearFilters() {
    _searchController.clear();
    _setFilter(const PokemonFilter());
  }

  Future<void> _openFilterSheet(List<Pokemon> pokemon) async {
    final result = await showModalBottomSheet<PokemonFilter>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (context) => FractionallySizedBox(
        heightFactor: 0.8,
        child: FilterSheet(
          initial: _filter,
          allDetails: _allDetails(pokemon),
        ),
      ),
    );
    // The screen may have closed while the sheet was open.
    if (!mounted || result == null) return;
    _setFilter(result);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final onToggleTheme = widget.onToggleTheme;

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
        actions: [
          if (onToggleTheme != null)
            IconButton(
              tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
              icon: Icon(
                isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
              ),
              onPressed: () => onToggleTheme(brightness),
            ),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: AppTheme.backgroundFor(brightness),
        ),
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<List<Pokemon>>(
      future: _pokemonFuture,
      builder: (context, snapshot) {
        // 1. Loading
        if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingView();
        }

        // 2. Error
        if (snapshot.hasError) {
          final error = snapshot.error;
          return ErrorView(
            message: error is PokemonServiceException
                ? error.message
                : 'Something unexpected happened. Please try again.',
            onRetry: _reload,
          );
        }

        // 3. Empty
        final pokemon = snapshot.data ?? const <Pokemon>[];
        if (pokemon.isEmpty) {
          return EmptyView(onRetry: _reload);
        }

        // 4. Data: search/filter bar above the grid
        return Column(
          children: [
            SearchFilterBar(
              controller: _searchController,
              filter: _filter,
              onChanged: _setFilter,
              onOpenFilters: () => _openFilterSheet(pokemon),
            ),
            Expanded(child: _buildResults(pokemon)),
          ],
        );
      },
    );
  }

  Widget _buildResults(List<Pokemon> pokemon) {
    // Name/number search only needs the list we already have.
    if (!_filter.needsDetails) {
      return _grid(pokemon.where((p) => _filter.matches(p, null)).toList());
    }

    // Type, generation, stage, ... need every Pokémon's details.
    return FutureBuilder<Map<int, PokemonDetails?>>(
      future: _allDetails(pokemon),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const LoadingView(message: 'Loading Pokédex data...');
        }
        final details = snapshot.data ?? const {};
        return _grid(
          pokemon.where((p) => _filter.matches(p, details[p.id])).toList(),
        );
      },
    );
  }

  Widget _grid(List<Pokemon> results) {
    if (results.isEmpty) {
      return NoMatchesView(onClear: _clearFilters);
    }
    return RefreshIndicator(
      onRefresh: _reload,
      child: PokemonGrid(pokemon: results, service: _service),
    );
  }
}
