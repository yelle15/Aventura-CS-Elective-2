import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../services/pokemon_service.dart';
import 'pokemon_details_provider.dart';
import 'service_provider.dart';

enum PokedexStatus { loading, success, error }

class PokemonListState {
  const PokemonListState({
    this.status = PokedexStatus.loading,
    this.pokemon = const [],
    this.errorMessage,
    this.isRefreshing = false,
  });

  final PokedexStatus status;
  final List<Pokemon> pokemon;
  final String? errorMessage;
  final bool isRefreshing;

  bool get isLoading => status == PokedexStatus.loading;

  PokemonListState copyWith({
    PokedexStatus? status,
    List<Pokemon>? pokemon,
    String? errorMessage,
    bool? isRefreshing,
  }) {
    return PokemonListState(
      status: status ?? this.status,
      pokemon: pokemon ?? this.pokemon,
      errorMessage: errorMessage,
      isRefreshing: isRefreshing ?? this.isRefreshing,
    );
  }
}

class PokemonListNotifier extends Notifier<PokemonListState> {
  static const int limit = 30;

  int _requestId = 0;
  bool _disposed = false;

  @override
  PokemonListState build() {
    ref.onDispose(() => _disposed = true);
    Future.microtask(fetchPokemon);
    return const PokemonListState();
  }

  Future<void> fetchPokemon({bool showLoading = true}) async {
    if (_disposed) return;
    final requestId = ++_requestId;

    if (showLoading || state.pokemon.isEmpty) {
      state = state.copyWith(status: PokedexStatus.loading);
    } else {
      state = state.copyWith(isRefreshing: true);
    }

    final service = ref.read(pokemonServiceProvider);
    try {
      final result = await service.fetchPokemon(limit: limit);
      if (_isStale(requestId)) return;

      state = PokemonListState(
        status: PokedexStatus.success,
        pokemon: List.unmodifiable(result),
      );
      ref.read(pokemonDetailsProvider.notifier).loadAll(result);
    } on PokemonServiceException catch (e) {
      if (_isStale(requestId)) return;
      _setError(e.message);
    } catch (_) {
      if (_isStale(requestId)) return;
      _setError('Something unexpected happened. Please try again.');
    }
  }

  void _setError(String message) {
    state = state.copyWith(
      status: PokedexStatus.error,
      errorMessage: message,
      isRefreshing: false,
    );
  }

  bool _isStale(int requestId) => _disposed || requestId != _requestId;
}

final pokemonListProvider =
    NotifierProvider<PokemonListNotifier, PokemonListState>(
  PokemonListNotifier.new,
);
