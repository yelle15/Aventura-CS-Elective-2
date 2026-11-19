import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/app_theme.dart';

class StockLabel extends StatelessWidget {
  const StockLabel({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final (text, color) = !product.inStock
        ? ('Out of stock', Theme.of(context).colorScheme.error)
        : product.isLowStock
            ? ('Only ${product.stock} left', AppTheme.rating)
            : ('${product.stock} in stock', AppTheme.success);
    return Text(
      text,
      style: TextStyle(
        color: color,
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
