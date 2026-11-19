import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';
import '../services/category_service.dart';
import '../services/order_service.dart';
import '../services/product_service.dart';
import '../services/profile_service.dart';
import '../services/storage_service.dart';

final supabaseClientProvider =
    Provider<SupabaseClient>((ref) => Supabase.instance.client);

final authServiceProvider = Provider<AuthService>(
  (ref) => SupabaseAuthService(ref.watch(supabaseClientProvider)),
);

final profileServiceProvider = Provider<ProfileService>(
  (ref) => SupabaseProfileService(ref.watch(supabaseClientProvider)),
);

final categoryServiceProvider = Provider<CategoryService>(
  (ref) => SupabaseCategoryService(ref.watch(supabaseClientProvider)),
);

final productServiceProvider = Provider<ProductService>(
  (ref) => SupabaseProductService(ref.watch(supabaseClientProvider)),
);

final storageServiceProvider = Provider<StorageService>(
  (ref) => SupabaseStorageService(ref.watch(supabaseClientProvider)),
);

final orderServiceProvider = Provider<OrderService>(
  (ref) => SupabaseOrderService(ref.watch(supabaseClientProvider)),
);
