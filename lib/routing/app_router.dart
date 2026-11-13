import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/product.dart';
import '../providers/auth_provider.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_confirmation_screen.dart';
import '../screens/home_screen.dart';
import '../screens/login_screen.dart';
import '../screens/product_detail_loader.dart';
import '../screens/product_detail_screen.dart';
import '../services/cart_service.dart';
import '../screens/wishlist_screen.dart';

GoRouter createAppRouter(VoidCallback onThemeToggle, AuthProvider auth) {
  return GoRouter(
    refreshListenable: auth,
    redirect: (context, state) {
      final onLogin = state.matchedLocation == '/login';
      if (!auth.isSignedIn) return onLogin ? null : '/login';
      if (onLogin) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/',
        builder: (context, state) => HomeScreen(onThemeToggle: onThemeToggle),
      ),
      GoRoute(
        path: '/wishlist',
        builder: (context, state) => WishlistScreen(onThemeToggle: onThemeToggle),
      ),
      GoRoute(
        path: '/cart',
        builder: (context, state) => CartScreen(onThemeToggle: onThemeToggle),
      ),
      GoRoute(
        path: '/checkout',
        redirect: (context, state) {
          final selectedItems = state.extra is List<CartItem>
              ? state.extra as List<CartItem>
              : CartService.instance.items;
          return selectedItems.isEmpty ? '/cart' : null;
        },
        builder: (context, state) {
          final items = state.extra is List<CartItem>
              ? state.extra as List<CartItem>
              : CartService.instance.items
                  .map(
                    (item) => CartItem(
                      product: item.product,
                      quantity: item.quantity,
                    ),
                  )
                  .toList();
          return CheckoutConfirmationScreen(
            onThemeToggle: onThemeToggle,
            checkoutItems: items,
          );
        },
      ),
      GoRoute(
        path: '/product/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          final extra = state.extra;
          if (extra is Product && extra.id == id) {
            return ProductDetailScreen(
              product: extra,
              onThemeToggle: onThemeToggle,
            );
          }
          return ProductDetailLoader(
            productId: id,
            onThemeToggle: onThemeToggle,
          );
        },
      ),
    ],
  );
}
