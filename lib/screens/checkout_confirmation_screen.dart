import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/cart_service.dart';
import '../widgets/navigation/app_bar.dart';

class CheckoutConfirmationScreen extends StatelessWidget {
  const CheckoutConfirmationScreen({
    super.key,
    required this.onThemeToggle,
    required this.checkoutItems,
  });

  final VoidCallback onThemeToggle;
  final List<CartItem> checkoutItems;

  String _formatPrice(double price) {
    return '\$${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}';
  }

  @override
  Widget build(BuildContext context) {
    final cart = CartService.instance;
    final items = checkoutItems;
    final total = items.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: RiftsAppBar(onThemeToggle: onThemeToggle, showBack: true),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(Icons.check_circle_rounded, color: colors.primary, size: 64),
                    const SizedBox(height: 16),
                    const Text(
                      'Order Confirmed',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Thank you for your purchase. Your order is being prepared.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 24),
                    ...items.map(
                      (item) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${item.product.name} x${item.quantity}',
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(_formatPrice(item.totalPrice)),
                          ],
                        ),
                      ),
                    ),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          _formatPrice(total),
                          style: TextStyle(
                            color: colors.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          cart.completeCheckout(items);
                          context.go('/');
                        },
                        child: const Text('CONTINUE SHOPPING'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
