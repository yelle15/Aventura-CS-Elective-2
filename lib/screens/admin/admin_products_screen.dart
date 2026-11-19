import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/product.dart';
import '../../providers/product_providers.dart';
import '../../widgets/app_navigation.dart';
import '../../widgets/catalog_section.dart';
import '../../widgets/product_card.dart';
import '../../widgets/riffs_app_bar.dart';
import '../../widgets/state_views.dart';

class AdminProductsScreen extends ConsumerWidget {
  const AdminProductsScreen({super.key});

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    Product product,
  ) async {
    final confirmed = await showConfirmDialog(
      context,
      title: 'Delete product?',
      message: 'Delete "${product.name}" from the shop? '
          'Past orders keep their copy of its name and price.',
      confirmLabel: 'Delete',
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref.read(catalogActionsProvider).deleteProduct(product.id);
      if (context.mounted) showMessage(context, 'Deleted ${product.name}.');
    } catch (error) {
      if (context.mounted) {
        showMessage(context, error.toString(), isError: true);
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final horizontal = MediaQuery.sizeOf(context).width < 600 ? 16.0 : 28.0;
    return Scaffold(
      appBar: const RiffsAppBar(title: 'Manage Products'),
      bottomNavigationBar: const AdminNavigation(selectedIndex: 0),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/admin/products/new'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add product'),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(productPageProvider);
          ref.invalidate(categoriesProvider);
          ref.invalidate(priceBoundsProvider);
          await ref.read(productPageProvider.future);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.fromLTRB(horizontal, 16, horizontal, 96),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1300),
              child: CatalogSection(
                cardBuilder: (context, product) => ProductCard(
                  product: product,
                  onTap: () =>
                      context.go('/admin/products/${product.id}/edit'),
                  actions: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () =>
                              context.go('/admin/products/${product.id}/edit'),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 38),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton.outlined(
                        tooltip: 'Delete ${product.name}',
                        onPressed: () => _delete(context, ref, product),
                        icon: Icon(
                          Icons.delete_outline_rounded,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
