import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/product.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider({ProductService? service})
      : _service = service ?? SupabaseProductService();

  final ProductService _service;

  static const int pageSize = 6;
  static const String allCategories = 'All Products';

  static const double priceStep = 100;

  List<Product> _products = const [];
  List<Product> _featured = const [];
  List<String> _categories = const [];
  int _totalCount = 0;
  int _currentPage = 0;
  String _selectedCategory = allCategories;
  PriceBounds? _priceBounds;
  RangeValues? _priceRange;
  bool _isLoading = false;
  bool _hasLoaded = false;
  String? _errorMessage;

  int _requestId = 0;

  List<Product> get products => _products;
  List<Product> get featured => _featured;
  List<String> get categories => _categories;
  int get totalCount => _totalCount;
  int get currentPage => _currentPage;
  String get selectedCategory => _selectedCategory;
  PriceBounds? get priceBounds => _priceBounds;
  RangeValues? get priceRange => _priceRange;
  bool get isLoading => _isLoading;
  bool get hasLoaded => _hasLoaded;
  String? get errorMessage => _errorMessage;

  int get totalPages =>
      _totalCount == 0 ? 1 : (_totalCount / pageSize).ceil();
  bool get hasPreviousPage => _currentPage > 0;
  bool get hasNextPage => _currentPage < totalPages - 1;

  int get firstItemNumber =>
      _products.isEmpty ? 0 : _currentPage * pageSize + 1;
  int get lastItemNumber =>
      _products.isEmpty ? 0 : firstItemNumber + _products.length - 1;

  bool get isPriceFiltered {
    final bounds = _priceBounds;
    final range = _priceRange;
    if (bounds == null || range == null) return false;
    return range.start > bounds.min || range.end < bounds.max;
  }

  Future<void> initialize() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loadFilterOptions(keepPriceSelection: false);
    } catch (error) {
      _errorMessage = describeError(error);
      _isLoading = false;
      notifyListeners();
      return;
    }

    await _loadPage(0);
  }

  Future<void> retry() {
    if (_categories.isEmpty && _priceBounds == null) return initialize();
    return _loadPage(_currentPage);
  }

  Future<void> refresh() => _loadPage(_currentPage);

  Future<void> _loadFilterOptions({required bool keepPriceSelection}) async {
    final categories = await _service.fetchCategories();
    final rawBounds = await _service.fetchPriceBounds();
    final featured = await _service.fetchFeatured();

    final wasFiltered = keepPriceSelection && isPriceFiltered;
    final previousRange = _priceRange;
    final bounds = rawBounds == null ? null : _roundBounds(rawBounds);

    _categories = categories;
    _featured = featured;
    _priceBounds = bounds;

    if (bounds == null) {
      _priceRange = null;
    } else if (wasFiltered && previousRange != null) {
      final start =
          previousRange.start.clamp(bounds.min, bounds.max).toDouble();
      final end = previousRange.end.clamp(start, bounds.max).toDouble();
      _priceRange = RangeValues(start, end);
    } else {
      _priceRange = RangeValues(bounds.min, bounds.max);
    }

    if (_selectedCategory != allCategories &&
        !categories.contains(_selectedCategory)) {
      _selectedCategory = allCategories;
    }
  }

  Future<void> _loadPage(int page) async {
    final requestId = ++_requestId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await _service.fetchProducts(
        page: page,
        pageSize: pageSize,
        category:
            _selectedCategory == allCategories ? null : _selectedCategory,
        minPrice: isPriceFiltered ? _priceRange!.start : null,
        maxPrice: isPriceFiltered ? _priceRange!.end : null,
      );
      if (requestId != _requestId) return;

      final lastPage = result.totalCount == 0
          ? 0
          : (result.totalCount - 1) ~/ pageSize;
      if (page > lastPage) {
        await _loadPage(lastPage);
        return;
      }

      _products = result.items;
      _totalCount = result.totalCount;
      _currentPage = page;
    } catch (error) {
      if (requestId != _requestId) return;
      _errorMessage = describeError(error);
    }

    _isLoading = false;
    _hasLoaded = true;
    notifyListeners();
  }

  void selectCategory(String category) {
    if (category == _selectedCategory) return;
    _selectedCategory = category;
    _loadPage(0);
  }

  void updatePriceRange(RangeValues values) {
    _priceRange = RangeValues(
      (values.start / priceStep).round() * priceStep,
      (values.end / priceStep).round() * priceStep,
    );
    notifyListeners();
  }

  void applyPriceRange() => _loadPage(0);

  void resetPriceRange() {
    final bounds = _priceBounds;
    if (bounds == null) return;
    _priceRange = RangeValues(bounds.min, bounds.max);
    _loadPage(0);
  }

  void goToPage(int page) {
    if (page < 0 || page >= totalPages || page == _currentPage) return;
    _loadPage(page);
  }

  void nextPage() => goToPage(_currentPage + 1);

  void previousPage() => goToPage(_currentPage - 1);

  Future<Product?> getProductById(String id) async {
    for (final product in [..._products, ..._featured]) {
      if (product.id == id) return product;
    }
    return _service.fetchProductById(id);
  }

  Future<Product> updateProduct(
    String id, {
    String? name,
    double? price,
  }) async {
    final updated = await _service.updateProduct(id, name: name, price: price);
    _products = [for (final p in _products) p.id == id ? updated : p];
    _featured = [for (final p in _featured) p.id == id ? updated : p];
    notifyListeners();

    await _reloadAfterChange();
    return updated;
  }

  Future<void> deleteProduct(String id) async {
    await _service.deleteProduct(id);
    await _reloadAfterChange();
  }

  Future<void> _reloadAfterChange() async {
    try {
      await _loadFilterOptions(keepPriceSelection: true);
    } catch (_) {}
    await _loadPage(_currentPage);
  }

  PriceBounds _roundBounds(PriceBounds bounds) {
    final min = (bounds.min / priceStep).floorToDouble() * priceStep;
    var max = (bounds.max / priceStep).ceilToDouble() * priceStep;
    if (max <= min) max = min + priceStep;
    return PriceBounds(min, max);
  }

  String describeError(Object error) {
    if (error is PostgrestException) return error.message;
    if (error is AuthException) return error.message;
    final text = error.toString();
    if (text.contains('SocketException') ||
        text.contains('ClientException') ||
        text.contains('Failed host lookup')) {
      return 'Could not reach Supabase. Check your internet connection and '
          'the URL/anon key in main.dart.';
    }
    return text;
  }
}
