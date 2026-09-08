import 'package:flutter/material.dart';

import '../data/products.dart';
import '../models/product.dart';
import '../widgets/home/hero_banner.dart';
import '../widgets/navigation/app_bar.dart';
import '../widgets/navigation/bottom_navigation.dart';
import '../widgets/product/product_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onThemeToggle});

  final VoidCallback onThemeToggle;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _productsKey = GlobalKey();
  String _selectedCategory = 'All Products';

  List<String> get _categories => products
      .map((product) => product.category)
      .toSet()
      .toList();

    List<Product> get _visibleProducts => _selectedCategory == 'All Products'
      ? products
      : products
        .where((product) => product.category == _selectedCategory)
        .toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RiftsAppBar(onThemeToggle: widget.onThemeToggle),
      bottomNavigationBar: const RiftsBottomNavigation(),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          MediaQuery.sizeOf(context).width < 600 ? 26 : 20,
          0,
          MediaQuery.sizeOf(context).width < 600 ? 26 : 20,
          24,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1300),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HeroBanner(
                  onShopPressed: () {
                    Scrollable.ensureVisible(
                      _productsKey.currentContext!,
                      alignment: 0.05,
                      duration: const Duration(milliseconds: 500),
                    );
                  },
                ),
                Container(
                  key: _productsKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Text(
                        'All Products',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final category in [
                            'All Products',
                            ..._categories,
                          ])
                            FilterChip(
                              label: Text(category),
                              selected: _selectedCategory == category,
                              onSelected: (_) {
                                setState(() {
                                  _selectedCategory = category;
                                });
                              },
                              showCheckmark: false,
                              selectedColor: Theme.of(context)
                                  .colorScheme
                                  .primary,
                              labelStyle: TextStyle(
                                color: _selectedCategory == category
                                    ? Theme.of(context).colorScheme.onPrimary
                                    : Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ProductGrid(products: _visibleProducts),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
