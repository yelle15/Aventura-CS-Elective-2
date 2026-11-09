import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final current = provider.currentPage;
    final total = provider.totalPages;
    final enabled = !provider.isLoading;

    return Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 6,
          runSpacing: 6,
          children: [
            IconButton.outlined(
              tooltip: 'Previous page',
              onPressed: enabled && provider.hasPreviousPage
                  ? provider.previousPage
                  : null,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            for (final page in _visiblePages(current, total))
              page == null
                  ? const SizedBox(
                      width: 24,
                      child: Text('…', textAlign: TextAlign.center),
                    )
                  : _PageNumberButton(
                      page: page,
                      isSelected: page == current,
                      onPressed:
                          enabled ? () => provider.goToPage(page) : null,
                    ),
            IconButton.outlined(
              tooltip: 'Next page',
              onPressed:
                  enabled && provider.hasNextPage ? provider.nextPage : null,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Page ${current + 1} of $total',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  static List<int?> _visiblePages(int current, int total) {
    if (total <= 7) return [for (var i = 0; i < total; i++) i];

    final pages = <int?>[0];
    final start = math.max(1, math.min(current - 1, total - 4));
    final end = math.min(total - 2, math.max(current + 1, 3));
    if (start > 1) pages.add(null);
    for (var i = start; i <= end; i++) {
      pages.add(i);
    }
    if (end < total - 2) pages.add(null);
    pages.add(total - 1);
    return pages;
  }
}

class _PageNumberButton extends StatelessWidget {
  const _PageNumberButton({
    required this.page,
    required this.isSelected,
    required this.onPressed,
  });

  final int page;
  final bool isSelected;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final style = ButtonStyle(
      minimumSize: const WidgetStatePropertyAll(Size(40, 40)),
      padding: const WidgetStatePropertyAll(EdgeInsets.zero),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    final label = Text('${page + 1}');

    return Semantics(
      label: 'Page ${page + 1}',
      selected: isSelected,
      child: isSelected
          ? FilledButton(onPressed: () {}, style: style, child: label)
          : OutlinedButton(onPressed: onPressed, style: style, child: label),
    );
  }
}
