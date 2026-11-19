import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/order_providers.dart';
import '../../widgets/app_navigation.dart';
import '../../widgets/order_card.dart';
import '../../widgets/riffs_app_bar.dart';
import '../../widgets/state_views.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(myOrdersProvider);

    return Scaffold(
      appBar: const RiffsAppBar(title: 'My Orders'),
      bottomNavigationBar: const CustomerNavigation(selectedIndex: 2),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(myOrdersProvider.future),
        child: orders.when(
          loading: () => const LoadingView(),
          error: (error, _) => ListView(
            children: [
              ErrorView(
                error: error,
                onRetry: () => ref.invalidate(myOrdersProvider),
              ),
            ],
          ),
          data: (items) => items.isEmpty
              ? ListView(
                  children: [
                    MessageView(
                      icon: Icons.receipt_long_outlined,
                      title: 'No orders yet',
                      message: 'Orders you place will show up here.',
                      actionLabel: 'Start shopping',
                      onAction: () => context.go('/'),
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: OrderCard(order: items[index]),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}
