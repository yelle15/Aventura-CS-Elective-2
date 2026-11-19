import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_exception.dart';
import '../models/product_category.dart';

abstract class CategoryService {
  Future<List<ProductCategory>> fetchCategories();

  Future<void> createCategory(String name);

  Future<void> renameCategory(int id, String name);

  Future<void> deleteCategory(int id);
}

class SupabaseCategoryService implements CategoryService {
  SupabaseCategoryService(this._client);

  final SupabaseClient _client;

  @override
  Future<List<ProductCategory>> fetchCategories() {
    return guardSupabase(() async {
      final rows = await _client
          .from('categories')
          .select('id, name')
          .order('name', ascending: true);
      return rows.map(ProductCategory.fromMap).toList();
    });
  }

  @override
  Future<void> createCategory(String name) {
    return guardSupabase(() async {
      await _client.from('categories').insert({'name': name}).select('id');
    });
  }

  @override
  Future<void> renameCategory(int id, String name) {
    return guardSupabase(() async {
      final rows = await _client
          .from('categories')
          .update({'name': name})
          .eq('id', id)
          .select('id');
      if (rows.isEmpty) throw const PermissionDeniedException();
    });
  }

  @override
  Future<void> deleteCategory(int id) {
    return guardSupabase(() async {
      final rows =
          await _client.from('categories').delete().eq('id', id).select('id');
      if (rows.isEmpty) throw const PermissionDeniedException();
    });
  }
}
