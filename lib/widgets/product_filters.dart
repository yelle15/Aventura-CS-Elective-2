import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/formatters.dart';
import '../models/product_filter.dart';
import '../providers/product_providers.dart';
import '../theme/app_theme.dart';

class ProductFilters extends ConsumerStatefulWidget {
  const ProductFilters({super.key});

  @override
  ConsumerState<ProductFilters> createState() => _ProductFiltersState();
}

class _ProductFiltersState extends ConsumerState<ProductFilters> {
  bool _showPrice = true;

  @override
  Widget build(BuildContext context) {
    final priceApplied = ref.watch(
      productFilterProvider.select((filter) => filter.priceRange != null),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: _SearchField()),
            const SizedBox(width: 10),
            _PriceToggle(
              open: _showPrice,
              active: priceApplied,
              onPressed: () => setState(() => _showPrice = !_showPrice),
            ),
          ],
        ),
        const SizedBox(height: 14),
        const _CategoryChips(),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          alignment: Alignment.topCenter,
          child: _showPrice
              ? const Padding(
                  padding: EdgeInsets.only(top: 14),
                  child: _PriceSlider(),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

class _PriceToggle extends StatelessWidget {
  const _PriceToggle({
    required this.open,
    required this.active,
    required this.onPressed,
  });

  final bool open;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      tooltip: open ? 'Hide price filter' : 'Show price filter',
      onPressed: onPressed,
      icon: const Icon(Icons.tune_rounded),
      style: IconButton.styleFrom(
        fixedSize: const Size(56, 56),
        foregroundColor: open ? Colors.white : AppTheme.red,
        backgroundColor: open ? AppTheme.red : AppTheme.panel(context),
        side: BorderSide(
          color: open ? AppTheme.red : AppTheme.outline(context),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
    return Badge(
      isLabelVisible: active,
      backgroundColor: open ? Colors.white : AppTheme.red,
      smallSize: 10,
      child: button,
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
        prefixIcon: const Padding(
          padding: EdgeInsets.only(left: 6),
          child: Icon(Icons.search_rounded),
        ),
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                tooltip: 'Clear search',
                onPressed: _clear,
                icon: const Icon(Icons.close_rounded),
              ),
        fillColor: AppTheme.panel(context),
      ),
    );
  }
}

class _CategoryChips extends ConsumerWidget {
  const _CategoryChips();

  static IconData _iconFor(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('bass')) return Icons.graphic_eq_rounded;
    if (lower.contains('electric')) return Icons.bolt_rounded;
    if (lower.contains('acoustic')) return Icons.music_note_rounded;
    if (lower.contains('amp')) return Icons.speaker_rounded;
    if (lower.contains('pedal') || lower.contains('effect')) {
      return Icons.tune_rounded;
    }
    if (lower.contains('access')) return Icons.headphones_rounded;
    return Icons.queue_music_rounded;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categories = ref.watch(categoriesProvider);
    final selected = ref.watch(
      productFilterProvider.select((filter) => filter.categoryId),
    );
    final notifier = ref.read(productFilterProvider.notifier);

    return categories.when(
      loading: () => const SizedBox(
        height: 48,
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
      data: (items) => SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        child: Row(
          children: [
            _chip(
              context,
              'All',
              Icons.local_fire_department_rounded,
              selected == null,
              () => notifier.selectCategory(null),
            ),
            for (final category in items)
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: _chip(
                  context,
                  category.name,
                  _iconFor(category.name),
                  selected == category.id,
                  () => notifier.selectCategory(category.id),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _chip(
    BuildContext context,
    String label,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final colors = Theme.of(context).colorScheme;
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? Colors.white : AppTheme.red.withAlpha(32),
            ),
            child: Icon(icon, size: 16, color: AppTheme.red),
          ),
          const SizedBox(width: 8),
          Text(label),
        ],
      ),
      selected: isSelected,
      onSelected: (_) => onTap(),
      showCheckmark: false,
      selectedColor: AppTheme.red,
      backgroundColor: AppTheme.panel(context),
      side: BorderSide(
        color: isSelected ? AppTheme.red : AppTheme.outline(context),
      ),
      shape: const StadiumBorder(),
      padding: const EdgeInsets.fromLTRB(4, 4, 8, 4),
      labelPadding: const EdgeInsets.only(left: 2, right: 4),
      labelStyle: TextStyle(
        color: isSelected ? colors.onPrimary : colors.onSurface,
        fontWeight: FontWeight.w700,
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
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 4),
      decoration: BoxDecoration(
        color: AppTheme.panel(context),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppTheme.outline(context)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AppTheme.red.withAlpha(32),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.payments_outlined,
                  size: 17,
                  color: AppTheme.red,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Price range',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Flexible(
                flex: 3,
                child: Text(
                  '${formatPeso(current.start)} – ${formatPeso(current.end)}',
                  textAlign: TextAlign.right,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
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
