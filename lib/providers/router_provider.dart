import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/order.dart';
import '../models/product.dart';
import '../screens/admin/admin_categories_screen.dart';
import '../screens/admin/admin_orders_screen.dart';
import '../screens/admin/admin_products_screen.dart';
import '../screens/admin/product_form_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/customer/cart_screen.dart';
import '../screens/customer/checkout_confirmation_screen.dart';
import '../screens/customer/order_history_screen.dart';
import '../screens/customer/product_detail_screen.dart';
import '../screens/customer/shop_screen.dart';
import '../screens/session_screen.dart';
import 'auth_providers.dart';

const _authPages = {'/login', '/signup'};

String? redirectForSession(Ref ref, String location) {
  final auth = ref.read(authUserIdProvider);
  final atAuthPage = _authPages.contains(location);
  final atSession = location == '/session';

  if (!auth.hasValue) {
    if (auth.hasError) return atAuthPage ? null : '/login';
    return atSession ? null : '/session';
  }

  final userId = auth.value;
  if (userId == null) return atAuthPage ? null : '/login';

  final profileState = ref.read(currentProfileProvider);
  final profile = profileState.value;
  if (profileState.hasError || profile == null || profile.id != userId) {
    return atSession ? null : '/session';
  }

  final home = profile.isAdmin ? '/admin/products' : '/';
  if (atAuthPage || atSession) return home;

  final inAdminArea = location.startsWith('/admin');
  if (profile.isAdmin && !inAdminArea) return home;
  if (!profile.isAdmin && inAdminArea) return home;
  return null;
}

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(authUserIdProvider, (_, _) => refresh.value++);
  ref.listen(currentProfileProvider, (_, _) => refresh.value++);

  final router = GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) => redirectForSession(ref, state.matchedLocation),
    routes: [
      GoRoute(
        path: '/session',
        builder: (context, state) => const SessionScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => const ShopScreen(),
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) => ProductDetailScreen(
          productId: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
          initialProduct:
              state.extra is Product ? state.extra as Product : null,
        ),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/checkout/confirmation',
        redirect: (context, state) =>
            state.extra is OrderReceipt ? null : '/orders',
        builder: (context, state) => CheckoutConfirmationScreen(
          receipt: state.extra! as OrderReceipt,
        ),
      ),
      GoRoute(
        path: '/orders',
        builder: (context, state) => const OrderHistoryScreen(),
      ),
      GoRoute(
        path: '/admin/products',
        builder: (context, state) => const AdminProductsScreen(),
      ),
      GoRoute(
        path: '/admin/products/new',
        builder: (context, state) => const ProductFormScreen(),
      ),
      GoRoute(
        path: '/admin/products/:id/edit',
        builder: (context, state) => ProductFormScreen(
          productId: int.tryParse(state.pathParameters['id'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/admin/categories',
        builder: (context, state) => const AdminCategoriesScreen(),
      ),
      GoRoute(
        path: '/admin/orders',
        builder: (context, state) => const AdminOrdersScreen(),
      ),
    ],
  );

  ref.onDispose(() {
    router.dispose();
    refresh.dispose();
  });
  return router;
});
