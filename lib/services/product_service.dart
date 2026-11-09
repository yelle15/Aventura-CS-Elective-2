import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart' show supabase;
import '../models/product.dart';

class ProductPage {
  const ProductPage({required this.items, required this.totalCount});

  final List<Product> items;
  final int totalCount;
}

class PriceBounds {
  const PriceBounds(this.min, this.max);

  final double min;
  final double max;
}

abstract class ProductService {
  Future<ProductPage> fetchProducts({
    required int page,
    required int pageSize,
    String? category,
    double? minPrice,
    double? maxPrice,
  });

  Future<PriceBounds?> fetchPriceBounds();

  Future<List<String>> fetchCategories();

  Future<List<Product>> fetchFeatured({int limit = 5});

  Future<Product?> fetchProductById(String id);

  Future<Product> updateProduct(String id, {String? name, double? price});

  Future<void> deleteProduct(String id);
}

class SupabaseProductService implements ProductService {
  static const _table = 'products';

  @override
  Future<ProductPage> fetchProducts({
    required int page,
    required int pageSize,
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    final from = page * pageSize;
    final to = from + pageSize - 1;

    var query = supabase.from(_table).select();
    if (category != null) {
      query = query.eq('category', category);
    }
    if (minPrice != null) {
      query = query.gte('price', minPrice);
    }
    if (maxPrice != null) {
      query = query.lte('price', maxPrice);
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
  }

  @override
  Future<PriceBounds?> fetchPriceBounds() async {
    final cheapest = await supabase
        .from(_table)
        .select('price')
        .order('price', ascending: true)
        .limit(1)
        .maybeSingle();
    final priciest = await supabase
        .from(_table)
        .select('price')
        .order('price', ascending: false)
        .limit(1)
        .maybeSingle();

    if (cheapest == null || priciest == null) return null;
    return PriceBounds(
      (cheapest['price'] as num).toDouble(),
      (priciest['price'] as num).toDouble(),
    );
  }

  @override
  Future<List<String>> fetchCategories() async {
    final rows = await supabase
        .from(_table)
        .select('category')
        .order('category', ascending: true);
    return rows.map((row) => row['category'] as String).toSet().toList();
  }

  @override
  Future<List<Product>> fetchFeatured({int limit = 5}) async {
    final rows = await supabase
        .from(_table)
        .select()
        .order('rating', ascending: false)
        .limit(limit);
    return rows.map(Product.fromMap).toList();
  }

  @override
  Future<Product?> fetchProductById(String id) async {
    final row =
        await supabase.from(_table).select().eq('id', id).maybeSingle();
    return row == null ? null : Product.fromMap(row);
  }

  @override
  Future<Product> updateProduct(
    String id, {
    String? name,
    double? price,
  }) async {
    final changes = <String, dynamic>{
      'name': ?name,
      'price': ?price,
    };
    final row = await supabase
        .from(_table)
        .update(changes)
        .eq('id', id)
        .select()
        .single();
    return Product.fromMap(row);
  }

  @override
  Future<void> deleteProduct(String id) async {
    final deleted =
        await supabase.from(_table).delete().eq('id', id).select();
    if (deleted.isEmpty) {
      throw PostgrestException(
        message:
            'Nothing was deleted. Check the DELETE policy on the products table.',
      );
    }
  }
}
