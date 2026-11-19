import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/product.dart';
import '../providers/product_providers.dart';
import 'pagination_bar.dart';
import 'product_filters.dart';
import 'product_grid.dart';
import 'state_views.dart';

class CatalogSection extends ConsumerWidget {
  const CatalogSection({super.key, required this.cardBuilder});

  final Widget Function(BuildContext context, Product product) cardBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final page = ref.watch(productPageProvider);
    final filter = ref.watch(productFilterProvider);
    final filterNotifier = ref.read(productFilterProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ProductFilters(),
        const SizedBox(height: 16),
        page.when(
          skipLoadingOnReload: true,
          loading: () => const LoadingView(),
          error: (error, _) => ErrorView(
            error: error,
            onRetry: () => ref.invalidate(productPageProvider),
          ),
          data: (result) {
            if (result.items.isEmpty) {
              return MessageView(
                icon: Icons.search_off_rounded,
                title: 'No products found',
                message: filter.hasFilters
                    ? 'Nothing matches your search, category and price range.'
                    : 'There are no products in the shop yet.',
                actionLabel: filter.hasFilters ? 'Clear filters' : null,
                onAction: filter.hasFilters ? filterNotifier.reset : null,
              );
            }
            final first = filter.page * productPageSize + 1;
            final last = first + result.items.length - 1;
            final totalPages = (result.totalCount / productPageSize).ceil();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Showing $first–$last of ${result.totalCount} products',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 6),
                SizedBox(
                  height: 3,
                  child: page.isLoading ? const LinearProgressIndicator() : null,
                ),
                const SizedBox(height: 8),
                ProductGrid(products: result.items, itemBuilder: cardBuilder),
                const SizedBox(height: 20),
                PaginationBar(
                  currentPage: filter.page,
                  totalPages: totalPages,
                  enabled: !page.isLoading,
                  onPageSelected: filterNotifier.goToPage,
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
