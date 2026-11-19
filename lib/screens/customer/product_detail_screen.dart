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
        padding: const EdgeInsets.all(20),
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
      height: 360,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? AppTheme.backgroundSecondary
            : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: ClipRect(child: ProductImage(url: product.imageUrl, iconSize: 96)),
    );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.categoryName.toUpperCase(),
          style: const TextStyle(
            color: AppTheme.red,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          product.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          formatPeso(product.price),
          style: theme.textTheme.headlineMedium?.copyWith(
            color: AppTheme.red,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 6),
        StockLabel(product: product),
        const SizedBox(height: 18),
        Text(
          product.description.isEmpty
              ? 'No description yet.'
              : product.description,
          style: const TextStyle(height: 1.5),
        ),
        const SizedBox(height: 24),
        if (inCart > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text('You have $inCart in your cart.'),
          ),
        Row(
          children: [
            QuantityStepper(
              quantity: quantity,
              min: available == 0 ? 0 : 1,
              max: available,
              onChanged: (value) => setState(() => _quantity = value),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 48,
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
            ),
          ],
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
      children: [photo, const SizedBox(height: 20), info],
    );
  }
}
