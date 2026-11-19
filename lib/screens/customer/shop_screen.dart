import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/product_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_navigation.dart';
import '../../widgets/catalog_section.dart';
import '../../widgets/featured_carousel.dart';
import '../../widgets/hero_banner.dart';
import '../../widgets/product_card.dart';
import '../../widgets/riffs_app_bar.dart';
import 'add_to_cart.dart';

class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen> {
  final _productsKey = GlobalKey();

  Future<void> _refresh() async {
    ref.invalidate(productPageProvider);
    ref.invalidate(featuredProductsProvider);
    ref.invalidate(categoriesProvider);
    ref.invalidate(priceBoundsProvider);
    await ref.read(productPageProvider.future);
  }

  @override
  Widget build(BuildContext context) {
    final horizontal = MediaQuery.sizeOf(context).width < 600 ? 20.0 : 28.0;
    return Scaffold(
      appBar: const RiffsAppBar(),
      bottomNavigationBar: const CustomerNavigation(selectedIndex: 0),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(horizontal, 0, horizontal, 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  HeroBanner(
                    onShopPressed: () {
                      final target = _productsKey.currentContext;
                      if (target == null) return;
                      Scrollable.ensureVisible(
                        target,
                        alignment: 0.05,
                        duration: const Duration(milliseconds: 500),
                      );
                    },
                  ),
                  const FeaturedCarousel(),
                  const SizedBox(height: 24),
                  Text(
                    'All Products',
                    key: _productsKey,
                    style: AppTheme.display(
                      fontSize: 28,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 12),
                  CatalogSection(
                    cardBuilder: (context, product) => ProductCard(
                      product: product,
                      onTap: () =>
                          context.go('/product/${product.id}', extra: product),
                      actions: AddToCartButton(product: product),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
