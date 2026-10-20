import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../models/pokemon_details.dart';
import 'service_provider.dart';

class PokemonDetailsState {
  const PokemonDetailsState({
    this.loaded = const {},
    this.failed = const {},
    this.pending = const {},
  });

  final Map<int, PokemonDetails> loaded;
  final Set<int> failed;
  final Set<int> pending;

  bool get isLoading => pending.isNotEmpty;

  List<PokemonDetails> get all => loaded.values.toList();
}

class PokemonDetailsNotifier extends Notifier<PokemonDetailsState> {
  bool _disposed = false;

  @override
  PokemonDetailsState build() {
    ref.onDispose(() => _disposed = true);
    return const PokemonDetailsState();
  }

  void loadAll(List<Pokemon> pokemon) {
    final missing = [
      for (final p in pokemon)
        if (!state.loaded.containsKey(p.id) && !state.pending.contains(p.id))
          p.id,
    ];
    if (missing.isEmpty) return;

    state = PokemonDetailsState(
      loaded: state.loaded,
      failed: state.failed.difference(missing.toSet()),
      pending: {...state.pending, ...missing},
    );
    for (final id in missing) {
      _load(id);
    }
  }

  void retry(int id) {
    if (state.pending.contains(id)) return;
    state = PokemonDetailsState(
      loaded: state.loaded,
      failed: {...state.failed}..remove(id),
      pending: {...state.pending, id},
    );
    _load(id);
  }

  Future<void> _load(int id) async {
    final service = ref.read(pokemonServiceProvider);
    try {
      final details = await service.fetchDetails(id);
      if (_disposed) return;
      state = PokemonDetailsState(
        loaded: {...state.loaded, id: details},
        failed: state.failed,
        pending: {...state.pending}..remove(id),
      );
    } catch (_) {
      if (_disposed) return;
      state = PokemonDetailsState(
        loaded: state.loaded,
        failed: {...state.failed, id},
        pending: {...state.pending}..remove(id),
      );
    }
  }
}

final pokemonDetailsProvider =
    NotifierProvider<PokemonDetailsNotifier, PokemonDetailsState>(
  PokemonDetailsNotifier.new,
);
