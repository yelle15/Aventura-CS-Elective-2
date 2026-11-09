import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/product_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';

class PriceRangeFilter extends StatelessWidget {
  const PriceRangeFilter({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProductProvider>();
    final bounds = provider.priceBounds;
    final range = provider.priceRange;
    if (bounds == null || range == null || bounds.max <= bounds.min) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.backgroundSecondary : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, size: 18, color: colors.primary),
              const SizedBox(width: 8),
              Text(
                'Price range',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              if (provider.isPriceFiltered)
                TextButton(
                  onPressed: provider.resetPriceRange,
                  style: TextButton.styleFrom(
                    visualDensity: VisualDensity.compact,
                  ),
                  child: const Text('Reset'),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _PriceTag(label: 'Min', value: formatPeso(range.start)),
              const Spacer(),
              _PriceTag(label: 'Max', value: formatPeso(range.end)),
            ],
          ),
          RangeSlider(
            values: range,
            min: bounds.min,
            max: bounds.max,
            labels: RangeLabels(
              formatPeso(range.start),
              formatPeso(range.end),
            ),
            onChanged: provider.updatePriceRange,
            onChangeEnd: (_) => provider.applyPriceRange(),
          ),
        ],
      ),
    );
  }
}

class _PriceTag extends StatelessWidget {
  const _PriceTag({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: [
          TextSpan(
            text: '$label  ',
            style: TextStyle(color: colors.onSurfaceVariant, fontSize: 12),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: colors.onSurface,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
