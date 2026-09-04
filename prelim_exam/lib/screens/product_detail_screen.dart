import 'package:flutter/material.dart';

import '../models/product.dart';
import '../widgets/navigation/app_bar.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key, required this.product});

  final Product product;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: RiftsAppBar(onThemeToggle: () {}, showBack: true),
      body: const SizedBox.shrink(),
    );
  }
}
