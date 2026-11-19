import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_exception.dart';

abstract class StorageService {
  Future<String> uploadProductImage({
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  });
}

class SupabaseStorageService implements StorageService {
  SupabaseStorageService(this._client);

  final SupabaseClient _client;

  static const _bucket = 'product-images';

  @override
  Future<String> uploadProductImage({
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) {
    return guardSupabase(() async {
      final safeName = fileName
          .toLowerCase()
          .replaceAll(RegExp(r'[^a-z0-9._-]'), '_');
      final path =
          'products/${DateTime.now().millisecondsSinceEpoch}_$safeName';
      await _client.storage.from(_bucket).uploadBinary(
            path,
            bytes,
            fileOptions: FileOptions(contentType: contentType, upsert: false),
          );
      return _client.storage.from(_bucket).getPublicUrl(path);
    });
  }
}
