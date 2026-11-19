import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../models/product_category.dart';
import '../models/product_filter.dart';
import 'service_providers.dart';

const productPageSize = 6;
const priceStep = 100.0;

class ProductFilterNotifier extends Notifier<ProductFilter> {
  @override
  ProductFilter build() => const ProductFilter();

  void selectCategory(int? categoryId) =>
      state = state.withCategory(categoryId);

  void search(String text) {
    final trimmed = text.trim();
    if (trimmed == state.search) return;
    state = state.withSearch(trimmed);
  }

  void setPriceRange(PriceRange? range) => state = state.withPriceRange(range);

  void goToPage(int page) {
    if (page < 0 || page == state.page) return;
    state = state.withPage(page);
  }

  void reset() => state = const ProductFilter();
}

final productFilterProvider =
    NotifierProvider<ProductFilterNotifier, ProductFilter>(
  ProductFilterNotifier.new,
);

final productPageProvider = FutureProvider<ProductPage>((ref) {
  final filter = ref.watch(productFilterProvider);
  return ref.watch(productServiceProvider).fetchProducts(
        page: filter.page,
        pageSize: productPageSize,
        categoryId: filter.categoryId,
        minPrice: filter.priceRange?.min,
        maxPrice: filter.priceRange?.max,
        search: filter.search,
      );
});

final priceBoundsProvider = FutureProvider<PriceBounds?>((ref) async {
  final bounds = await ref.watch(productServiceProvider).fetchPriceBounds();
  if (bounds == null) return null;
  final min = (bounds.min / priceStep).floorToDouble() * priceStep;
  var max = (bounds.max / priceStep).ceilToDouble() * priceStep;
  if (max <= min) max = min + priceStep;
  return PriceBounds(min, max);
});

final featuredProductsProvider = FutureProvider<List<Product>>(
  (ref) => ref.watch(productServiceProvider).fetchFeatured(),
);

final productByIdProvider = FutureProvider.family<Product?, int>(
  (ref, id) => ref.watch(productServiceProvider).fetchProduct(id),
);

final categoriesProvider = FutureProvider<List<ProductCategory>>(
  (ref) => ref.watch(categoryServiceProvider).fetchCategories(),
);

class CatalogActions {
  CatalogActions(this._ref);

  final Ref _ref;

  Future<String> uploadImage({
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) {
    return _ref.read(storageServiceProvider).uploadProductImage(
          bytes: bytes,
          fileName: fileName,
          contentType: contentType,
        );
  }

  Future<Product> saveProduct(ProductInput input, {int? productId}) async {
    final service = _ref.read(productServiceProvider);
    final saved = productId == null
        ? await service.createProduct(input)
        : await service.updateProduct(productId, input);
    _refreshProducts(productId: saved.id);
    return saved;
  }

  Future<void> deleteProduct(int productId) async {
    await _ref.read(productServiceProvider).deleteProduct(productId);
    _refreshProducts(productId: productId);
  }

  Future<void> createCategory(String name) async {
    await _ref.read(categoryServiceProvider).createCategory(name);
    _ref.invalidate(categoriesProvider);
  }

  Future<void> renameCategory(int id, String name) async {
    await _ref.read(categoryServiceProvider).renameCategory(id, name);
    _ref.invalidate(categoriesProvider);
    _refreshProducts();
  }

  Future<void> deleteCategory(int id) async {
    await _ref.read(categoryServiceProvider).deleteCategory(id);
    _ref.invalidate(categoriesProvider);
    final filter = _ref.read(productFilterProvider);
    if (filter.categoryId == id) {
      _ref.read(productFilterProvider.notifier).selectCategory(null);
    }
  }

  void _refreshProducts({int? productId}) {
    _ref.invalidate(productPageProvider);
    _ref.invalidate(priceBoundsProvider);
    _ref.invalidate(featuredProductsProvider);
    if (productId != null) _ref.invalidate(productByIdProvider(productId));
  }
}

final catalogActionsProvider = Provider<CatalogActions>(CatalogActions.new);
