import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../theme/breakpoints.dart';
import 'product_card.dart';

class ProductGrid extends StatelessWidget {
  const ProductGrid({super.key, required this.products});

  final List<Product> products;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = productColumnsFor(constraints.maxWidth);
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: products.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: constraints.maxWidth < 600 ? 20 : 12,
            mainAxisSpacing: constraints.maxWidth < 600 ? 30 : 12,
            mainAxisExtent: constraints.maxWidth < 600 ? 290 : null,
            childAspectRatio: .72,
          ),
          itemBuilder: (context, index) =>
              ProductCard(product: products[index]),
        );
      },
    );
  }
}
