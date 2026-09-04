import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../data/products.dart';
import '../screens/home_screen.dart';
import '../screens/product_detail_screen.dart';

GoRouter createAppRouter(VoidCallback onThemeToggle) {
  return GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => HomeScreen(onThemeToggle: onThemeToggle),
      ),
      GoRoute(
        path: '/product/355-epiphone',
        builder: (context, state) =>
            ProductDetailScreen(product: products.first),
      ),
    ],
  );
}
