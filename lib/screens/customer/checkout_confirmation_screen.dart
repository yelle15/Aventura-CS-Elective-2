import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatters.dart';
import '../../models/order.dart';
import '../../theme/app_theme.dart';
import '../../widgets/riffs_app_bar.dart';
import '../../widgets/riffs_decor.dart';

class CheckoutConfirmationScreen extends StatelessWidget {
  const CheckoutConfirmationScreen({super.key, required this.receipt});

  final OrderReceipt receipt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: const RiffsAppBar(title: 'Order placed'),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppTheme.redGradient,
                      boxShadow: AppTheme.redGlow(alpha: 90),
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 62,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Thank you for your order!',
                  textAlign: TextAlign.center,
                  style: AppTheme.display(
                    fontSize: 28,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Your gear is reserved. Time to start practicing.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.panel(context),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppTheme.outline(context)),
                    boxShadow: AppTheme.softShadow(context),
                  ),
                  child: Column(
                    children: [
                      _row(
                        context,
                        Icons.receipt_long_outlined,
                        'Order number',
                        formatOrderNumber(receipt.orderId),
                      ),
                      const Divider(height: 28),
                      _row(
                        context,
                        Icons.payments_outlined,
                        'Total paid',
                        formatPeso(receipt.total),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                GradientFill(
                  radius: 18,
                  child: SizedBox(
                    height: 54,
                    child: FilledButton(
                      onPressed: () => context.go('/orders'),
                      style: FilledButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: const Text('View my orders'),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 52,
                  child: OutlinedButton(
                    onPressed: () => context.go('/'),
                    child: const Text('Continue shopping'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _row(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppTheme.red.withAlpha(30),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 18, color: AppTheme.red),
        ),
        const SizedBox(width: 12),
        Text(label),
        const Spacer(),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
              ),
        ),
      ],
    );
  }
}
