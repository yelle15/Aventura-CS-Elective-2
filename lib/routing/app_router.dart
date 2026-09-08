import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/products.dart';
import '../screens/cart_screen.dart';
import '../screens/checkout_confirmation_screen.dart';
import '../screens/home_screen.dart';
import '../screens/product_detail_screen.dart';
import '../services/cart_service.dart';
import '../screens/wishlist_screen.dart';

GoRouter createAppRouter(VoidCallback onThemeToggle) {
  return GoRouter(
    routes: [
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
          final id = state.pathParameters['id'];
          final product = products.firstWhere(
            (p) => p.id == id,
            orElse: () => products.first,
          );
          return ProductDetailScreen(
            product: product,
            onThemeToggle: onThemeToggle,
          );
        },
      ),
    ],
  );
}
