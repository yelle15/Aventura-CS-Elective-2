import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/formatters.dart';
import '../models/product_filter.dart';
import '../providers/product_providers.dart';
import '../theme/app_theme.dart';

class ProductFilters extends StatelessWidget {
  const ProductFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SearchField(),
        SizedBox(height: 12),
        _CategoryChips(),
        SizedBox(height: 12),
        _PriceSlider(),
      ],
    );
  }
}

class _SearchField extends ConsumerStatefulWidget {
  const _SearchField();

  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: ref.read(productFilterProvider).search,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref.read(productFilterProvider.notifier).search(text);
    });
  }

  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    setState(() {});
    ref.read(productFilterProvider.notifier).search('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search guitars and basses',
        prefixIcon: const Icon(Icons.search_rounded),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: _clear,
                icon: const Icon(Icons.close_rounded),
              ),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final selected = ref.watch(
      productFilterProvider.select((filter) => filter.categoryId),
    );
    final notifier = ref.read(productFilterProvider.notifier);

    return categories.when(
      loading: () => const SizedBox(
        height: 40,
        child: Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (error, _) => Row(
        children: [
          const Expanded(child: Text('Could not load categories.')),
          TextButton(
            onPressed: () => ref.invalidate(categoriesProvider),
            child: const Text('Retry'),
          ),
        ],
      ),
      data: (items) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _chip(context, 'All', selected == null, () => notifier.selectCategory(null)),
          for (final category in items)
            _chip(
              context,
              category.name,
              selected == category.id,
              () => notifier.selectCategory(category.id),
            ),
        ],
      ),
    );
  }

  Widget _chip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final colors = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: colors.primary,
      labelStyle: TextStyle(
        color: isSelected ? colors.onPrimary : colors.onSurface,
      ),
    );
  }
}

class _PriceSlider extends ConsumerStatefulWidget {
  const _PriceSlider();

  @override
  ConsumerState<_PriceSlider> createState() => _PriceSliderState();
}

class _PriceSliderState extends ConsumerState<_PriceSlider> {
  RangeValues? _dragging;

  @override
  Widget build(BuildContext context) {
    final boundsAsync = ref.watch(priceBoundsProvider);
    final applied = ref.watch(
      productFilterProvider.select((filter) => filter.priceRange),
    );
    if (boundsAsync.hasError && !boundsAsync.hasValue) {
      return Row(
        children: [
          const Icon(Icons.error_outline_rounded, size: 20),
          const SizedBox(width: 8),
          const Expanded(child: Text('Could not load the price range.')),
          TextButton(
            onPressed: () => ref.invalidate(priceBoundsProvider),
            child: const Text('Retry'),
          ),
        ],
      );
    }
    if (!boundsAsync.hasValue) {
      return const Row(
        children: [
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Text('Loading price range…'),
        ],
      );
    }
    final bounds = boundsAsync.value;
    if (bounds == null || bounds.max <= bounds.min) {
      return const SizedBox.shrink();
    }

    final current = _dragging ??
        RangeValues(
          (applied?.min ?? bounds.min).clamp(bounds.min, bounds.max).toDouble(),
          (applied?.max ?? bounds.max).clamp(bounds.min, bounds.max).toDouble(),
        );
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 2),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? AppTheme.backgroundSecondary
            : AppTheme.lightCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.tune_rounded, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                'Price range',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Text(
                '${formatPeso(current.start)} – ${formatPeso(current.end)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              if (applied != null)
                TextButton(
                  onPressed: () {
                    setState(() => _dragging = null);
                    ref.read(productFilterProvider.notifier).setPriceRange(null);
                  },
                  child: const Text('Reset'),
                ),
            ],
          ),
          RangeSlider(
            values: current,
            min: bounds.min,
            max: bounds.max,
            divisions: ((bounds.max - bounds.min) / priceStep).round(),
            labels: RangeLabels(
              formatPeso(current.start),
              formatPeso(current.end),
            ),
            onChanged: (values) => setState(() => _dragging = values),
            onChangeEnd: (values) {
              setState(() => _dragging = null);
              final isFullRange =
                  values.start <= bounds.min && values.end >= bounds.max;
              ref.read(productFilterProvider.notifier).setPriceRange(
                    isFullRange ? null : PriceRange(values.start, values.end),
                  );
            },
          ),
        ],
      ),
    );
  }
}
