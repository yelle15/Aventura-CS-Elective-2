import 'package:flutter/foundation.dart';

import '../models/pokemon.dart';
import '../models/pokemon_details.dart';
import '../models/pokemon_filter.dart';
import '../services/pokemon_service.dart';

enum PokedexStatus { loading, success, error }

class PokedexProvider extends ChangeNotifier {
  PokedexProvider({PokemonService? service, this.limit = 30})
      : _service = service ?? PokemonService();

  final PokemonService _service;
  final int limit;

  PokedexStatus _status = PokedexStatus.loading;
  List<Pokemon> _pokemon = const [];
  String? _errorMessage;
  bool _isRefreshing = false;

  Pokemon? _selectedPokemon;
  PokemonFilter _filter = const PokemonFilter();
  PokemonFilter _draftFilter = const PokemonFilter();

  final Map<int, PokemonDetails> _details = {};
  final Set<int> _failedDetails = {};

  int _requestId = 0;
  bool _disposed = false;

  PokedexStatus get status => _status;
  bool get isLoading => _status == PokedexStatus.loading;
  bool get hasError => _status == PokedexStatus.error;

  bool get isRefreshing => _isRefreshing;

  String? get errorMessage => _errorMessage;
  List<Pokemon> get pokemon => _pokemon;
  Pokemon? get selectedPokemon => _selectedPokemon;
  PokemonFilter get filter => _filter;

  PokemonFilter get draftFilter => _draftFilter;

  PokemonDetails? detailsFor(int id) => _details[id];
  bool detailsFailed(int id) => _failedDetails.contains(id);

  bool get isLoadingDetails => _pokemon.any(
        (p) => !_details.containsKey(p.id) && !_failedDetails.contains(p.id),
      );

  List<PokemonDetails> get loadedDetails => [
        for (final p in _pokemon)
          if (_details[p.id] case final d?) d,
      ];

  List<Pokemon> get visiblePokemon =>
      _pokemon.where((p) => _filter.matches(p, _details[p.id])).toList();

  Future<void> fetchPokemon({bool showLoading = true}) async {
    final requestId = ++_requestId;
    _errorMessage = null;
    if (showLoading || _pokemon.isEmpty) {
      _status = PokedexStatus.loading;
    } else {
      _isRefreshing = true;
    }
    _notify();

    try {
      final result = await _service.fetchPokemon(limit: limit);
      if (_isStale(requestId)) return;

      _pokemon = List.unmodifiable(result);
      _failedDetails.clear();
      _status = PokedexStatus.success;
    } on PokemonServiceException catch (e) {
      if (_isStale(requestId)) return;
      _setError(e.message);
    } catch (_) {
      if (_isStale(requestId)) return;
      _setError('Something unexpected happened. Please try again.');
    }

    _isRefreshing = false;
    _notify();

    if (_status == PokedexStatus.success) _loadMissingDetails();
  }

  void selectPokemon(Pokemon pokemon) {
    if (identical(_selectedPokemon, pokemon)) return;
    _selectedPokemon = pokemon;
    _notify();
  }

  void setFilter(PokemonFilter filter) {
    _filter = filter;
    _notify();
  }

  void updateFilter(PokemonFilter Function(PokemonFilter current) update) =>
      setFilter(update(_filter));

  void clearFilters() => setFilter(const PokemonFilter());

  void startFilterDraft() {
    _draftFilter = _filter;
    _notify();
  }

  void updateDraftFilter(PokemonFilter Function(PokemonFilter draft) update) {
    _draftFilter = update(_draftFilter);
    _notify();
  }

  void applyDraftFilter() => setFilter(_draftFilter);

  Future<void> retryDetails(int id) async {
    _failedDetails.remove(id);
    _notify();
    await _loadDetails(id);
  }

  void _loadMissingDetails() {
    for (final p in _pokemon) {
      if (!_details.containsKey(p.id)) _loadDetails(p.id);
    }
  }

  Future<void> _loadDetails(int id) async {
    try {
      final details = await _service.fetchDetails(id);
      if (_disposed) return;
      _details[id] = details;
      _failedDetails.remove(id);
    } catch (_) {
      if (_disposed) return;
      _failedDetails.add(id);
    }
    _notify();
  }

  void _setError(String message) {
    _status = PokedexStatus.error;
    _errorMessage = message;
  }

  bool _isStale(int requestId) => _disposed || requestId != _requestId;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _service.dispose();
    super.dispose();
  }
}
