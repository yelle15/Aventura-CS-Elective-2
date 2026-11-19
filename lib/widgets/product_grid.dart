import 'package:flutter/material.dart';

import '../models/product.dart';
import '../theme/breakpoints.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({
    super.key,
    required this.products,
    required this.itemBuilder,
  });

  final List<Product> products;
  final Widget Function(BuildContext context, Product product) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: productColumnsFor(width),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            mainAxisExtent: 360,
          ),
          itemBuilder: (context, index) =>
              itemBuilder(context, products[index]),
        );
      },
    );
  }
}
