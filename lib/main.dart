import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'pages/fruit-list-page.dart';
import 'pages/fruit-detail-page.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const FruitListPage(),
      routes: [
        GoRoute(
          path: 'fruit/:name',
          name: 'fruitDetail',
          builder: (context, state) {
            final fruitId = state.pathParameters['name'] ?? '';
            return FruitDetailPage(fruitId: fruitId);
          },
        ),
      ],
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Nested Route Scenario',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF419A94)),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}