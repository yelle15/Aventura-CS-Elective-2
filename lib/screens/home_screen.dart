import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/home/featured_carousel.dart';
import '../widgets/home/hero_banner.dart';
import '../widgets/home/price_range_filter.dart';
import '../widgets/navigation/app_bar.dart';
import '../widgets/navigation/bottom_navigation.dart';
import '../widgets/product/pagination_bar.dart';
import '../widgets/product/product_grid.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onThemeToggle});

  final VoidCallback onThemeToggle;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey _productsKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();

    return Scaffold(
      appBar: RiftsAppBar(onThemeToggle: widget.onThemeToggle),
      bottomNavigationBar: const RiftsBottomNavigation(),
      body: RefreshIndicator(
        onRefresh: provider.refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(
            MediaQuery.sizeOf(context).width < 600 ? 26 : 20,
            0,
            MediaQuery.sizeOf(context).width < 600 ? 26 : 20,
            24,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1300),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HeroBanner(
                    onShopPressed: () {
                      Scrollable.ensureVisible(
                        _productsKey.currentContext!,
                        alignment: 0.05,
                        duration: const Duration(milliseconds: 500),
                      );
                    },
                  ),
                  const FeaturedCarousel(),
                  Container(
                    key: _productsKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          'All Products',
                          style: AppTheme.display(
                            fontSize: 28,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _buildCategoryChips(context, provider),
                        const SizedBox(height: 12),
                        const PriceRangeFilter(),
                        const SizedBox(height: 12),
                        _buildProductArea(context, provider),
                      ],
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

  Widget _buildCategoryChips(BuildContext context, ProductProvider provider) {
    final colors = Theme.of(context).colorScheme;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final category in [
          ProductProvider.allCategories,
          ...provider.categories,
        ])
          FilterChip(
            label: Text(category),
            selected: provider.selectedCategory == category,
            onSelected: (_) => provider.selectCategory(category),
            showCheckmark: false,
            selectedColor: colors.primary,
            labelStyle: TextStyle(
              color: provider.selectedCategory == category
                  ? colors.onPrimary
                  : colors.onSurface,
            ),
          ),
      ],
    );
  }

  Widget _buildProductArea(BuildContext context, ProductProvider provider) {
    if (!provider.hasLoaded && provider.isLoading) {
      return const SizedBox(
        height: 240,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.errorMessage != null) {
      return _MessageView(
        icon: Icons.cloud_off_rounded,
        title: 'Could not load products',
        message: provider.errorMessage!,
        actionLabel: 'Try again',
        onAction: provider.retry,
      );
    }

    if (provider.products.isEmpty) {
      return _MessageView(
        icon: Icons.search_off_rounded,
        title: 'No products found',
        message: 'Nothing matches this category and price range.',
        actionLabel: provider.isPriceFiltered ? 'Reset price range' : null,
        onAction: provider.isPriceFiltered ? provider.resetPriceRange : null,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Showing ${provider.firstItemNumber}–${provider.lastItemNumber} '
          'of ${provider.totalCount} products',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 3,
          child: provider.isLoading ? const LinearProgressIndicator() : null,
        ),
        const SizedBox(height: 6),
        AnimatedOpacity(
          opacity: provider.isLoading ? 0.5 : 1,
          duration: const Duration(milliseconds: 150),
          child: ProductGrid(products: provider.products),
        ),
        const SizedBox(height: 20),
        const Center(child: PaginationBar()),
      ],
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 48, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(message, textAlign: TextAlign.center),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}
