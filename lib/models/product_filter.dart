class PriceRange {
  const PriceRange(this.min, this.max);

  final double min;
  final double max;

  @override
  bool operator ==(Object other) =>
      other is PriceRange && other.min == min && other.max == max;

  @override
  int get hashCode => Object.hash(min, max);
}

class ProductFilter {
  const ProductFilter({
    this.categoryId,
    this.search = '',
    this.priceRange,
    this.page = 0,
  });

  final int? categoryId;
  final String search;
  final PriceRange? priceRange;
  final int page;

  bool get hasFilters =>
      categoryId != null || search.isNotEmpty || priceRange != null;

  ProductFilter withCategory(int? categoryId) => ProductFilter(
        categoryId: categoryId,
        search: search,
        priceRange: priceRange,
      );

  ProductFilter withSearch(String search) => ProductFilter(
        categoryId: categoryId,
        search: search,
        priceRange: priceRange,
      );

  ProductFilter withPriceRange(PriceRange? priceRange) => ProductFilter(
        categoryId: categoryId,
        search: search,
        priceRange: priceRange,
      );

  ProductFilter withPage(int page) => ProductFilter(
        categoryId: categoryId,
        search: search,
        priceRange: priceRange,
        page: page,
      );

  @override
  bool operator ==(Object other) =>
      other is ProductFilter &&
      other.categoryId == categoryId &&
      other.search == search &&
      other.priceRange == priceRange &&
      other.page == page;

  @override
  int get hashCode => Object.hash(categoryId, search, priceRange, page);
}
