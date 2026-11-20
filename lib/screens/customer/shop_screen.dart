import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/auth_providers.dart';
import '../../providers/product_providers.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_navigation.dart';
import '../../widgets/catalog_section.dart';
import '../../widgets/featured_carousel.dart';
import '../../widgets/hero_banner.dart';
import '../../widgets/product_card.dart';
import '../../widgets/riffs_app_bar.dart';
import '../../widgets/riffs_decor.dart';
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

  Widget _contained(double horizontal, Widget child) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1300),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: horizontal),
          child: child,
        ),
      ),
    );
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
          padding: const EdgeInsets.fromLTRB(0, 4, 0, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _contained(horizontal, const _Greeting()),
              const SizedBox(height: 18),
              HeroBanner(
                horizontalPadding: horizontal,
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
              _contained(
                horizontal,
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const FeaturedCarousel(),
                    const SizedBox(height: 28),
                    SectionTitle(title: 'All Products', textKey: _productsKey),
                    const SizedBox(height: 14),
                    CatalogSection(
                      cardBuilder: (context, product) => ProductCard(
                        product: product,
                        onTap: () => context.go(
                          '/product/${product.id}',
                          extra: product,
                        ),
                        actions: AddToCartButton(product: product),
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

class _Greeting extends ConsumerWidget {
  const _Greeting();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(currentProfileProvider);
    final theme = Theme.of(context);
    final titleStyle = AppTheme.display(
      fontSize: 28,
      color: theme.colorScheme.onSurface,
    );

    final Widget title = profileState.when(
      skipLoadingOnReload: true,
      loading: () => Row(
        children: [
          Text('Hey', style: titleStyle),
          const SizedBox(width: 12),
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
      error: (error, _) => Row(
        children: [
          Flexible(
            child: Text(
              'Hey there',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: titleStyle,
            ),
          ),
          IconButton(
            tooltip: 'Reload your profile',
            onPressed: () => ref.invalidate(currentProfileProvider),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      data: (profile) {
        final first = profile?.firstname?.trim();
        final name = first != null && first.isNotEmpty
            ? first
            : profile?.displayName ?? 'there';
        return Text(
          'Hey, $name',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: titleStyle,
        );
      },
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        title,
        const SizedBox(height: 4),
        Text(
          'Ready to plug in? Pick your next guitar or bass.',
          style: theme.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
