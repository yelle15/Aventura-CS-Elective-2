import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/formatters.dart';
import '../../models/product.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/product_image.dart';
import '../../widgets/quantity_stepper.dart';
import '../../widgets/riffs_app_bar.dart';
import '../../widgets/riffs_decor.dart';
import '../../widgets/state_views.dart';
import '../../widgets/stock_label.dart';
import 'add_to_cart.dart';

class ProductDetailScreen extends ConsumerWidget {
  const ProductDetailScreen({
    super.key,
    required this.productId,
    this.initialProduct,
  });

  final int productId;
  final Product? initialProduct;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final product = ref.watch(productByIdProvider(productId));

    final Widget body;
    if (product.hasValue && product.value != null) {
      body = _ProductDetails(product: product.value!);
    } else if (product.isLoading && initialProduct != null) {
      body = _ProductDetails(product: initialProduct!);
    } else {
      body = product.when(
        loading: () => const LoadingView(),
        error: (error, _) => ErrorView(
          error: error,
          onRetry: () => ref.invalidate(productByIdProvider(productId)),
        ),
        data: (_) => MessageView(
          icon: Icons.search_off_rounded,
          title: 'Product not found',
          message: 'This product may have been removed from the shop.',
          actionLabel: 'Back to shop',
          onAction: () => context.go('/'),
        ),
      );
    }

    return Scaffold(
      appBar: const RiffsAppBar(showBack: true, title: 'Product'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: body,
          ),
        ),
      ),
    );
  }
}

class _ProductDetails extends ConsumerStatefulWidget {
  const _ProductDetails({required this.product});

  final Product product;

  @override
  ConsumerState<_ProductDetails> createState() => _ProductDetailsState();
}

class _ProductDetailsState extends ConsumerState<_ProductDetails> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final theme = Theme.of(context);
    final inCart = ref.watch(
      cartProvider.select(
        (items) => items
            .where((item) => item.product.id == product.id)
            .fold(0, (sum, item) => sum + item.quantity),
      ),
    );
    final available = (product.stock - inCart).clamp(0, product.stock).toInt();
    final quantity = available == 0 ? 0 : _quantity.clamp(1, available).toInt();
    final isWide = MediaQuery.sizeOf(context).width >= 768;

    final photo = Container(
      height: isWide ? 460 : 340,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withAlpha(28)),
        boxShadow: AppTheme.redGlow(alpha: 40),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: TieDyeBackground(seed: product.id)),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(28, 56, 28, 28),
              child: Opacity(
                opacity: product.inStock ? 1 : 0.5,
                child: ProductImage(url: product.imageUrl, iconSize: 96),
              ),
            ),
          ),
          if (product.categoryName.isNotEmpty)
            Positioned(
              left: 18,
              top: 18,
              right: 18,
              child: Align(
                alignment: Alignment.centerLeft,
                child: TagPill(
                  text: product.categoryName.toUpperCase(),
                  onDark: true,
                ),
              ),
            ),
        ],
      ),
    );

    final addButton = GradientFill(
      enabled: available > 0,
      radius: 18,
      child: SizedBox(
        height: 54,
        child: FilledButton.icon(
          onPressed: available == 0
              ? null
              : () {
                  addProductToCart(
                    context,
                    ref,
                    product,
                    quantity: quantity,
                  );
                  setState(() => _quantity = 1);
                },
          style: FilledButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          icon: const Icon(Icons.add_shopping_cart_rounded),
          label: Text(
            !product.inStock
                ? 'Sold out'
                : available == 0
                    ? 'Max in cart'
                    : 'Add to cart',
          ),
        ),
      ),
    );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Text(
                formatPeso(product.price),
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: AppTheme.red,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.panel(context),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.outline(context)),
              ),
              child: StockLabel(product: product),
            ),
          ],
        ),
        const SizedBox(height: 22),
        Text(
          'Description',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.description.isEmpty
              ? 'No description yet.'
              : product.description,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.55),
        ),
        const SizedBox(height: 22),
        if (inCart > 0)
          Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.red.withAlpha(26),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.red.withAlpha(90)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shopping_bag_outlined,
                  size: 18,
                  color: AppTheme.red,
                ),
                const SizedBox(width: 10),
                Expanded(child: Text('You have $inCart in your cart.')),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: Text(
                'Quantity',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            QuantityStepper(
              quantity: quantity,
              min: available == 0 ? 0 : 1,
              max: available,
              onChanged: (value) => setState(() => _quantity = value),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 12, 12),
          decoration: BoxDecoration(
            color: AppTheme.panel(context),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppTheme.outline(context)),
            boxShadow: AppTheme.softShadow(context),
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Total', style: theme.textTheme.bodySmall),
                  Text(
                    formatPeso(product.price * (quantity == 0 ? 1 : quantity)),
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(child: addButton),
            ],
          ),
        ),
      ],
    );

    if (isWide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: photo),
          const SizedBox(width: 32),
          Expanded(child: info),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [photo, const SizedBox(height: 22), info],
    );
  }
}
