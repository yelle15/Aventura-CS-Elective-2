import 'package:flutter/material.dart';

import '../core/formatters.dart';
import '../models/order.dart';
import '../theme/app_theme.dart';

class OrderStatusChip extends StatelessWidget {
  const OrderStatusChip({super.key, required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final color = switch (status) {
      'done' => AppTheme.success,
      'shipped' => Colors.blue,
      'cancelled' => Theme.of(context).colorScheme.error,
      _ => AppTheme.rating,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(35),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(140)),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class OrderCard extends StatelessWidget {
  const OrderCard({super.key, required this.order, this.statusControl});

  final Order order;
  final Widget? statusControl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        title: Row(
          children: [
            Text(
              'Order ${formatOrderNumber(order.id)}',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(width: 10),
            OrderStatusChip(status: order.status),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            [
              if (order.customerName != null || order.customerEmail != null)
                order.customerName ?? order.customerEmail!,
              formatDateTime(order.createdAt),
              '${order.itemCount} item${order.itemCount == 1 ? '' : 's'}',
            ].join(' · '),
          ),
        ),
        trailing: Text(
          formatPeso(order.total),
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          const Divider(),
          for (final item in order.items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      '${item.quantity} × ${item.productName}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text('${formatPeso(item.unitPrice)} each'),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 90,
                    child: Text(
                      formatPeso(item.subtotal),
                      textAlign: TextAlign.right,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ),
          if (statusControl != null) ...[
            const Divider(),
            statusControl!,
          ],
        ],
      ),
    );
  }
}
