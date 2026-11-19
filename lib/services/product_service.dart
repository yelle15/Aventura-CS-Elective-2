import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_exception.dart';
import '../models/product.dart';

abstract class ProductService {
  Future<ProductPage> fetchProducts({
    required int page,
    required int pageSize,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String search = '',
  });

  Future<PriceBounds?> fetchPriceBounds();

  Future<List<Product>> fetchFeatured({int limit = 5});

  Future<Product?> fetchProduct(int id);

  Future<Product> createProduct(ProductInput input);

  Future<Product> updateProduct(int id, ProductInput input);

  Future<void> deleteProduct(int id);
}

class SupabaseProductService implements ProductService {
  SupabaseProductService(this._client);

  final SupabaseClient _client;

  static const _table = 'products';
  static const _columns = '*, categories(name)';

  @override
  Future<ProductPage> fetchProducts({
    required int page,
    required int pageSize,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String search = '',
  }) {
    return guardSupabase(() async {
      final from = page * pageSize;
      final to = from + pageSize - 1;

      var query = _client.from(_table).select(_columns);
      if (categoryId != null) {
        query = query.eq('category_id', categoryId);
      }
      if (minPrice != null) {
        query = query.gte('price', minPrice);
      }
      if (maxPrice != null) {
        query = query.lte('price', maxPrice);
      }
      final term = search.replaceAll(RegExp(r'[%_,()]'), ' ').trim();
      if (term.isNotEmpty) {
        query = query.ilike('name', '%$term%');
      }

      final response = await query
          .order('price', ascending: true)
          .order('id', ascending: true)
          .range(from, to)
          .count(CountOption.exact);

      return ProductPage(
        items: response.data.map(Product.fromMap).toList(),
        totalCount: response.count,
      );
    });
  }

  @override
  Future<PriceBounds?> fetchPriceBounds() {
    return guardSupabase(() async {
      final cheapest = await _client
          .from(_table)
          .select('price')
          .order('price', ascending: true)
          .limit(1)
          .maybeSingle();
      final priciest = await _client
          .from(_table)
          .select('price')
          .order('price', ascending: false)
          .limit(1)
          .maybeSingle();
      if (cheapest == null || priciest == null) return null;
      return PriceBounds(
        parseDouble(cheapest['price']),
        parseDouble(priciest['price']),
      );
    });
  }

  @override
  Future<List<Product>> fetchFeatured({int limit = 5}) {
    return guardSupabase(() async {
      final rows = await _client
          .from(_table)
          .select(_columns)
          .gt('stock', 0)
          .order('price', ascending: false)
          .limit(limit);
      return rows.map(Product.fromMap).toList();
    });
  }

  @override
  Future<Product?> fetchProduct(int id) {
    return guardSupabase(() async {
      final row =
          await _client.from(_table).select(_columns).eq('id', id).maybeSingle();
      return row == null ? null : Product.fromMap(row);
    });
  }

  @override
  Future<Product> createProduct(ProductInput input) {
    return guardSupabase(() async {
      final row = await _client
          .from(_table)
          .insert(input.toMap())
          .select(_columns)
          .single();
      return Product.fromMap(row);
    });
  }

  @override
  Future<Product> updateProduct(int id, ProductInput input) {
    return guardSupabase(() async {
      final rows = await _client
          .from(_table)
          .update(input.toMap())
          .eq('id', id)
          .select(_columns);
      if (rows.isEmpty) throw const PermissionDeniedException();
      return Product.fromMap(rows.first);
    });
  }

  @override
  Future<void> deleteProduct(int id) {
    return guardSupabase(() async {
      final rows = await _client.from(_table).delete().eq('id', id).select('id');
      if (rows.isEmpty) throw const PermissionDeniedException();
    });
  }
}
