import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../services/cart_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common/app_image_placeholder.dart';
import '../widgets/navigation/app_bar.dart';
import '../widgets/navigation/bottom_navigation.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key, required this.onThemeToggle});

  final VoidCallback onThemeToggle;

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    CartService.instance.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    CartService.instance.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  String _formatPrice(double price) {
    return '\$${price.toStringAsFixed(0).replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',')}';
  }

  Future<void> _confirmCheckout(
    BuildContext context,
    List<CartItem> checkoutItems,
  ) async {
    final total = checkoutItems.fold<double>(
      0,
      (sum, item) => sum + item.totalPrice,
    );
    final itemCount = checkoutItems.fold<int>(
      0,
      (sum, item) => sum + item.quantity,
    );
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Confirm Checkout'),
          content: Text(
            'Checkout $itemCount ${itemCount == 1 ? 'item' : 'items'} for ${_formatPrice(total)}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('CANCEL'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('CONFIRM'),
            ),
          ],
        );
      },
    );

    if (shouldContinue == true && context.mounted) {
      context.go('/checkout', extra: checkoutItems);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colors = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isDesktopOrTablet = screenWidth >= 800;

    return Scaffold(
      appBar: RiftsAppBar(onThemeToggle: widget.onThemeToggle),
      bottomNavigationBar: const RiftsBottomNavigation(selectedIndex: 2),
      body: Builder(
        builder: (context) {
          final cart = CartService.instance;
          final items = cart.items;

          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              screenWidth < 600 ? 16 : 24,
              20,
              screenWidth < 600 ? 16 : 24,
              32,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        const Icon(
                          Icons.shopping_bag_rounded,
                          color: AppTheme.red,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Shopping Cart',
                          style: TextStyle(
                            fontSize: screenWidth < 600 ? 22 : 26,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.red.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${cart.itemCount} ${cart.itemCount == 1 ? 'item' : 'items'}',
                            style: const TextStyle(
                              color: AppTheme.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (items.isNotEmpty)
                          TextButton.icon(
                            onPressed: () => CartService.instance.clearCart(),
                            icon: const Icon(Icons.delete_sweep_outlined, size: 18),
                            label: const Text('Clear'),
                            style: TextButton.styleFrom(
                              foregroundColor: colors.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    if (items.isEmpty)
                      _buildEmptyState(context, isDark)
                    else if (isDesktopOrTablet)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 7,
                            child: _buildCartItemsList(context, items, isDark, screenWidth),
                          ),
                          const SizedBox(width: 24),
                          Expanded(
                            flex: 5,
                            child: _buildOrderSummary(context, cart.subtotal, items, isDark),
                          ),
                        ],
                      )
                    else
                      Column(
                        children: [
                          _buildCartItemsList(context, items, isDark, screenWidth),
                          const SizedBox(height: 24),
                          _buildOrderSummary(context, cart.subtotal, items, isDark),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDark) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundSecondary : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outline,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.shopping_bag_outlined,
              size: 48,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Your cart is empty',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Looks like you haven\'t added any guitars or gear to your cart yet.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: colors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.go('/'),
            style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.explore_outlined, size: 20),
            label: const Text(
              'EXPLORE PRODUCTS',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemsList(
    BuildContext context,
    List<CartItem> items,
    bool isDark,
    double screenWidth,
  ) {
    final colors = Theme.of(context).colorScheme;
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final item = items[index];
        final product = item.product;
        final isCompact = screenWidth < 450;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppTheme.backgroundSecondary : AppTheme.lightCard,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: colors.outline,
            ),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Product Image
              InkWell(
                onTap: () => context.go('/product/${product.id}'),
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    color: colors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: ProductImage(
                        path: product.imagePath,
                        scale: product.imageScale,
                        showPlaceholder: false,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Details & Quantity
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () => context.go('/product/${product.id}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.category.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.red,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            product.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatPrice(product.price),
                            style: TextStyle(
                              fontSize: 12,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Quantity selector
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      runSpacing: 6,
                      spacing: 8,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: colors.outline.withValues(alpha: 0.35),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              InkWell(
                                onTap: () {
                                  CartService.instance.updateQuantity(
                                    product.id,
                                    item.quantity - 1,
                                  );
                                },
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(7),
                                  bottomLeft: Radius.circular(7),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Icon(Icons.remove, size: 16),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  '${item.quantity}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  CartService.instance.updateQuantity(
                                    product.id,
                                    item.quantity + 1,
                                  );
                                },
                                borderRadius: const BorderRadius.only(
                                  topRight: Radius.circular(7),
                                  bottomRight: Radius.circular(7),
                                ),
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  child: Icon(Icons.add, size: 16),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Subtotal: ${_formatPrice(item.totalPrice)}',
                          style: TextStyle(
                            fontSize: isCompact ? 12 : 15,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmCheckout(context, [
                          CartItem(
                            product: product,
                            quantity: item.quantity,
                          ),
                        ]),
                        icon: const Icon(Icons.lock_outline_rounded, size: 16),
                        label: const Text('CHECKOUT ITEM'),
                      ),
                    ),
                  ],
                ),
              ),

              // Delete button
              IconButton(
                onPressed: () {
                  CartService.instance.removeFromCart(product.id);
                },
                tooltip: 'Remove item',
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppTheme.neutral,
                  size: 20,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderSummary(
    BuildContext context,
    double subtotal,
    List<CartItem> items,
    bool isDark,
  ) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundSecondary : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Order Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                ),
              ),
              Text(
                _formatPrice(subtotal),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Estimated Shipping',
                style: TextStyle(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const Text(
                'FREE',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.success,
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                _formatPrice(subtotal),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _confirmCheckout(context, items),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary,
                foregroundColor: colors.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.lock_outline_rounded, size: 20),
              label: const Text(
                'CHECKOUT',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 0.8,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
