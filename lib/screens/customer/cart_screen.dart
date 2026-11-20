import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatters.dart';
import '../../models/cart_item.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_navigation.dart';
import '../../widgets/product_image.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/riffs_app_bar.dart';
import '../../widgets/riffs_decor.dart';
import '../../widgets/state_views.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  Future<void> _checkout(BuildContext context, WidgetRef ref) async {
    final receipt = await ref.read(checkoutProvider.notifier).placeOrder();
    if (receipt != null && context.mounted) {
      context.go('/checkout/confirmation', extra: receipt);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(cartProvider);
    final count = ref.watch(cartCountProvider);
    final total = ref.watch(cartTotalProvider);
    final checkout = ref.watch(checkoutProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const RiffsAppBar(title: 'Your Cart'),
      bottomNavigationBar: const CustomerNavigation(selectedIndex: 1),
      body: items.isEmpty
          ? MessageView(
              icon: Icons.shopping_bag_outlined,
              title: 'Your cart is empty',
              message: 'Add a guitar or bass from the shop to get started.',
              actionLabel: 'Browse the shop',
              onAction: () => context.go('/'),
            )
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) =>
                            _CartRow(item: items[index]),
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppTheme.panel(context),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(color: AppTheme.outline(context)),
                        boxShadow: AppTheme.softShadow(context),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (checkout.error != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.error.withAlpha(25),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: theme.colorScheme.error.withAlpha(110),
                                ),
                              ),
                              child: Text(
                                checkout.error!,
                                style: TextStyle(
                                  color: theme.colorScheme.error,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          Row(
                            children: [
                              Text(
                                '$count item${count == 1 ? '' : 's'}',
                                style: theme.textTheme.bodyLarge,
                              ),
                              const Spacer(),
                              Text(
                                'Total  ',
                                style: theme.textTheme.bodyLarge,
                              ),
                              Text(
                                formatPeso(total),
                                style: theme.textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          GradientFill(
                            enabled: !checkout.isPlacing,
                            radius: 18,
                            child: SizedBox(
                              height: 54,
                              child: FilledButton(
                                onPressed: checkout.isPlacing
                                    ? null
                                    : () => _checkout(context, ref),
                                style: FilledButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                child: checkout.isPlacing
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text('Checkout'),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _CartRow extends ConsumerWidget {
  const _CartRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.read(cartProvider.notifier);
    final product = item.product;
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      color: AppTheme.panel(context),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            SizedBox(
              width: 96,
              height: 96,
              child: ImageGlow(
                radius: 18,
                padding: const EdgeInsets.all(8),
                child: ClipRect(child: ProductImage(url: product.imageUrl)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (product.categoryName.isNotEmpty)
                    Text(
                      product.categoryName.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppTheme.red,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${formatPeso(product.price)} each',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (item.isAtStockLimit)
                    Text(
                      'Max available: ${product.stock}',
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  const SizedBox(height: 10),
                  QuantityStepper(
                    quantity: item.quantity,
                    max: product.stock,
                    onChanged: (value) => cart.setQuantity(product.id, value),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  tooltip: 'Remove ${product.name}',
                  onPressed: () => cart.remove(product.id),
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: theme.colorScheme.error,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.error.withAlpha(22),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  formatPeso(item.subtotal),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
