import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/order.dart';
import '../../providers/order_providers.dart';
import '../../widgets/app_navigation.dart';
import '../../widgets/order_card.dart';
import '../../widgets/riffs_app_bar.dart';
import '../../widgets/state_views.dart';

class AdminOrdersScreen extends ConsumerWidget {
  const AdminOrdersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(adminOrdersProvider);

    return Scaffold(
      appBar: const RiffsAppBar(title: 'All Orders'),
      bottomNavigationBar: const AdminNavigation(selectedIndex: 2),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(adminOrdersProvider.future),
        child: orders.when(
          loading: () => const LoadingView(),
          error: (error, _) => ListView(
            children: [
              ErrorView(
                error: error,
                onRetry: () => ref.invalidate(adminOrdersProvider),
              ),
            ],
          ),
          data: (items) => items.isEmpty
              ? ListView(
                  children: const [
                    MessageView(
                      icon: Icons.receipt_long_outlined,
                      title: 'No orders yet',
                      message: 'Customer orders will appear here.',
                    ),
                  ],
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) => Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: OrderCard(
                        order: items[index],
                        statusControl: _StatusControl(order: items[index]),
                      ),
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _StatusControl extends ConsumerStatefulWidget {
  const _StatusControl({required this.order});

  final Order order;

  @override
  ConsumerState<_StatusControl> createState() => _StatusControlState();
}

class _StatusControlState extends ConsumerState<_StatusControl> {
  bool _saving = false;

  Future<void> _change(String? status) async {
    if (status == null || status == widget.order.status) return;
    setState(() => _saving = true);
    try {
      await ref.read(orderActionsProvider).updateStatus(widget.order.id, status);
      if (mounted) showMessage(context, 'Order status set to $status.');
    } catch (error) {
      if (mounted) showMessage(context, error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Status', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: orderStatuses.contains(widget.order.status)
              ? widget.order.status
              : null,
          onChanged: _saving ? null : _change,
          items: [
            for (final status in orderStatuses)
              DropdownMenuItem(
                value: status,
                child: Text(status[0].toUpperCase() + status.substring(1)),
              ),
          ],
        ),
        if (_saving) ...[
          const SizedBox(width: 12),
          const SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ],
    );
  }
}
