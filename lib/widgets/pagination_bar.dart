import 'dart:math' as math;

import 'package:flutter/material.dart';

class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.currentPage,
    required this.totalPages,
    required this.onPageSelected,
    this.enabled = true,
  });

  final int currentPage;
  final int totalPages;
  final ValueChanged<int> onPageSelected;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (totalPages <= 1) return const SizedBox.shrink();

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
              onPressed: enabled && currentPage > 0
                  ? () => onPageSelected(currentPage - 1)
                  : null,
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            for (final page in _visiblePages())
              if (page == null)
                const SizedBox(
                  width: 24,
                  child: Text('…', textAlign: TextAlign.center),
                )
              else if (page == currentPage)
                FilledButton(
                  onPressed: () {},
                  style: _pageStyle,
                  child: Text('${page + 1}'),
                )
              else
                OutlinedButton(
                  onPressed: enabled ? () => onPageSelected(page) : null,
                  style: _pageStyle,
                  child: Text('${page + 1}'),
                ),
            IconButton.outlined(
              tooltip: 'Next page',
              onPressed: enabled && currentPage < totalPages - 1
                  ? () => onPageSelected(currentPage + 1)
                  : null,
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Page ${currentPage + 1} of $totalPages',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  static final _pageStyle = ButtonStyle(
    minimumSize: const WidgetStatePropertyAll(Size(40, 40)),
    padding: const WidgetStatePropertyAll(EdgeInsets.zero),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );

  List<int?> _visiblePages() {
    if (totalPages <= 7) return [for (var i = 0; i < totalPages; i++) i];
    final pages = <int?>[0];
    final start = math.max(1, math.min(currentPage - 1, totalPages - 4));
    final end = math.min(totalPages - 2, math.max(currentPage + 1, 3));
    if (start > 1) pages.add(null);
    for (var i = start; i <= end; i++) {
      pages.add(i);
    }
    if (end < totalPages - 2) pages.add(null);
    pages.add(totalPages - 1);
    return pages;
  }
}
