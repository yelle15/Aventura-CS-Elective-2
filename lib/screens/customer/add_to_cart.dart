import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/riffs_decor.dart';
import '../../widgets/state_views.dart';

void addProductToCart(
  BuildContext context,
  WidgetRef ref,
  Product product, {
  int quantity = 1,
}) {
  final result =
      ref.read(cartProvider.notifier).add(product, quantity: quantity);
  switch (result) {
    case AddToCartResult.added:
      showMessage(context, 'Added ${product.name} to your cart.');
    case AddToCartResult.outOfStock:
      showMessage(context, '${product.name} is out of stock.', isError: true);
    case AddToCartResult.stockLimitReached:
      showMessage(
        context,
        'Only ${product.stock} of ${product.name} available. '
        'Your cart has the maximum.',
        isError: true,
      );
  }
}

class AddToCartButton extends ConsumerWidget {
  const AddToCartButton({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inCart = ref.watch(
      cartProvider.select(
        (items) => items
            .where((item) => item.product.id == product.id)
            .fold(0, (sum, item) => sum + item.quantity),
      ),
    );
    final atLimit = inCart >= product.stock;
    final canAdd = product.inStock && !atLimit;

    return GradientFill(
      enabled: canAdd,
      radius: 14,
      child: SizedBox(
        width: double.infinity,
        height: 40,
        child: FilledButton.icon(
          onPressed: canAdd ? () => addProductToCart(context, ref, product) : null,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: Icon(
            product.inStock
                ? Icons.add_shopping_cart_rounded
                : Icons.remove_shopping_cart_outlined,
            size: 18,
          ),
          label: Text(
            !product.inStock
                ? 'Sold out'
                : atLimit
                    ? 'Max in cart'
                    : inCart > 0
                        ? 'Add more ($inCart)'
                        : 'Add to cart',
          ),
        ),
      ),
    );
  }
}
