import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../models/product.dart';
import '../services/cart_service.dart';
import '../services/wishlist_service.dart';
import '../theme/app_theme.dart';
import '../widgets/common/app_image_placeholder.dart';
import '../widgets/common/status_badge.dart';
import '../widgets/common/wishlist_modal.dart';
import '../widgets/navigation/app_bar.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    super.key,
    required this.product,
    this.onThemeToggle,
  });

  final Product product;
  final VoidCallback? onThemeToggle;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => ',');
  }

  void _toggleBookmark() {
    final isAdded = WishlistService.instance.toggleWishlist(widget.product);
    showWishlistModal(context, widget.product, isAdded);
  }

  void _addToCart() {
    CartService.instance.addToCart(widget.product, quantity: _quantity);
    context.go('/cart');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final formattedPrice = _formatPrice(widget.product.price);
    final isTabletOrDesktop = MediaQuery.sizeOf(context).width >= 768;

    return Scaffold(
      appBar: RiftsAppBar(
        onThemeToggle: widget.onThemeToggle ?? () {},
        showBack: true,
        actions: [
          if (widget.onThemeToggle != null)
            IconButton(
              onPressed: widget.onThemeToggle,
              tooltip: 'Toggle light and dark mode',
              icon: Icon(
                isDark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      bottomNavigationBar: _buildStickyBottomBar(isDark, formattedPrice),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isTabletOrDesktop ? 32 : 20,
          vertical: 20,
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: isTabletOrDesktop
                ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 5,
                        child: _buildProductPhoto(isDark),
                      ),
                      const SizedBox(width: 36),
                      Expanded(
                        flex: 6,
                        child: _buildProductInfo(
                          isDark: isDark,
                          formattedPrice: formattedPrice,
                        ),
                      ),
                    ],
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductPhoto(isDark),
                      const SizedBox(height: 20),
                      _buildProductInfo(
                        isDark: isDark,
                        formattedPrice: formattedPrice,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductPhoto(bool isDark) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      constraints: const BoxConstraints(minHeight: 280, maxHeight: 420),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundSecondary : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colors.outline,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: ProductImage(
              path: widget.product.imagePath,
              scale: widget.product.imageScale,
              showPlaceholder: false,
            ),
          ),
          if (widget.product.isNew)
            const Positioned(
              top: 14,
              left: 14,
              child: StatusBadge(label: 'NEW'),
            ),
          if (widget.product.isOnSale)
            const Positioned(
              top: 14,
              left: 14,
              child: StatusBadge(label: 'SALE'),
            ),
        ],
      ),
    );
  }

  Widget _buildProductInfo({
    required bool isDark,
    required String formattedPrice,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Category Badge & Add to wishlist button
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          runSpacing: 8,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppTheme.red.withAlpha(25),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: AppTheme.red.withAlpha(70),
                ),
              ),
              child: Text(
                widget.product.category.toUpperCase(),
                style: const TextStyle(
                  color: AppTheme.red,
                  fontWeight: FontWeight.w800,
                  fontSize: 11,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            ListenableBuilder(
              listenable: WishlistService.instance,
              builder: (context, _) {
                final isBookmarked = WishlistService.instance.isWishlisted(widget.product.id);
                return InkWell(
                  onTap: _toggleBookmark,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isBookmarked
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_border_rounded,
                          color: isBookmarked ? colors.primary : colors.onSurfaceVariant,
                          size: 20,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isBookmarked ? 'Wishlisted' : 'Add to wishlist',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isBookmarked ? colors.primary : colors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Product Name
        Text(
          widget.product.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: 10),

        // Rating & Reviews
        Row(
          children: [
                const Icon(Icons.star_rounded, color: AppTheme.rating, size: 20),
            const SizedBox(width: 4),
            Text(
              widget.product.rating.toStringAsFixed(1),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            Text(
              '(128 reviews)',
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                  color: colors.tertiary.withAlpha(25),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: colors.tertiary, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'In Stock',
                    style: TextStyle(
                      color: colors.tertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Price
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '₱$formattedPrice',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: AppTheme.red,
                  ),
            ),
            if (widget.product.isOnSale && widget.product.oldPrice != null) ...[
              const SizedBox(width: 12),
              Text(
                '₱${_formatPrice(widget.product.oldPrice!)}',
                style: TextStyle(
                  fontSize: 16,
                  decoration: TextDecoration.lineThrough,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 18),
        Divider(color: colors.outline),
        const SizedBox(height: 16),

        // Details Section
        Text(
          'Details',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.product.description,
          style: TextStyle(
            fontSize: 15,
            height: 1.5,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),

        // Specifications / Highlights
        _buildSpecsCard(isDark),
        const SizedBox(height: 24),

        // Quantity Selector (Solely Quantity)
        Row(
          children: [
            Text(
              'Quantity',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(width: 16),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: colors.outline,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove, size: 18),
                    onPressed: _quantity > 1
                        ? () => setState(() => _quantity--)
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      '$_quantity',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add, size: 18),
                    onPressed: () => setState(() => _quantity++),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecsCard(bool isDark) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: colors.outline,
        ),
      ),
      child: Column(
        children: [
          _buildSpecRow(
            icon: Icons.category_outlined,
            title: 'Category',
            value: widget.product.category,
            isDark: isDark,
          ),
          const Divider(height: 16),
          _buildSpecRow(
            icon: Icons.verified_user_outlined,
            title: 'Warranty',
            value: '1 Year Official Warranty',
            isDark: isDark,
          ),
          const Divider(height: 16),
          _buildSpecRow(
            icon: Icons.local_shipping_outlined,
            title: 'Delivery',
            value: 'Free Standard Shipping',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow({
    required IconData icon,
    required String title,
    required String value,
    required bool isDark,
  }) {
    final colors = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: colors.onSurfaceVariant,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13,
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStickyBottomBar(bool isDark, String formattedPrice) {
    final colors = Theme.of(context).colorScheme;
    final totalPrice = _formatPrice(widget.product.price * _quantity);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(
          top: BorderSide(
            color: colors.outline,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withAlpha(20),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Subtotal',
                style: TextStyle(
                  fontSize: 11,
                  color: colors.onSurfaceVariant,
                ),
              ),
              Text(
                '₱$totalPrice',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: colors.onSurface,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: SizedBox(
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _addToCart,
                icon: const Icon(Icons.shopping_cart_outlined, size: 18),
                label: const Text(
                  'Add to Cart',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
