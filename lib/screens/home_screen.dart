import 'package:flutter/material.dart';

import '../data/products.dart';
import '../models/product.dart';
import '../widgets/home/hero_banner.dart';
import '../widgets/home/product_categories.dart';
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
  String _selectedCategory = 'Guitars';

  List<Product> get _visibleProducts => products.where((product) {
    if (_selectedCategory == 'Guitars') {
      return product.category == 'Electric Guitars';
    }
    return product.category == 'Amplifiers';
  }).toList();

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
                const HeroBanner(),
                const SizedBox(height: 12),
                ProductCategories(
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                  },
                ),
                const SizedBox(height: 16),
                ProductGrid(products: _visibleProducts),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
