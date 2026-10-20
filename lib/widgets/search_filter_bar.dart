import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../providers/filter_provider.dart';
import 'card_palette.dart';
import 'filter_sheet.dart';

class SearchFilterBar extends ConsumerStatefulWidget {
  const SearchFilterBar({super.key});

  @override
  ConsumerState<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends ConsumerState<SearchFilterBar> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(filterProvider).query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    ref.read(filterDraftProvider.notifier).start();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (_) => const FractionallySizedBox(
        heightFactor: 0.8,
        child: FilterSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(filterProvider.select((f) => f.query), (previous, next) {
      if (_controller.text != next) _controller.text = next;
    });

    final scheme = Theme.of(context).colorScheme;
    final filter = ref.watch(filterProvider);
    final count = filter.sheetFilterCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  onChanged: (text) =>
                      ref.read(filterProvider.notifier).setQuery(text),
                  decoration: InputDecoration(
                    hintText: 'Search Pokémon by name or number...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: filter.query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () =>
                                ref.read(filterProvider.notifier).setQuery(''),
                          ),
                    filled: true,
                    fillColor: scheme.surface,
                    contentPadding: const EdgeInsets.symmetric(vertical: 0),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(28),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Badge(
                isLabelVisible: count > 0,
                label: Text('$count'),
                child: IconButton.filled(
                  tooltip: 'More filters',
                  onPressed: _openFilterSheet,
                  icon: const Icon(Icons.tune_rounded),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _TypeChip(
                  label: 'All types',
                  selected: filter.type == null,
                  onTap: () => ref.read(filterProvider.notifier).clearType(),
                ),
                for (final type in CardPalette.types)
                  _TypeChip(
                    label: prettify(type),
                    type: type,
                    selected: filter.type == type,
                    onTap: () => filter.type == type
                        ? ref.read(filterProvider.notifier).clearType()
                        : ref.read(filterProvider.notifier).selectType(type),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.type,
  });

  final String label;
  final String? type;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final t = type;
    final color = t == null ? scheme.primary : CardPalette.forType(t);

    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        avatar: t == null ? null : EnergyIcon(type: t, size: 18),
        showCheckmark: false,
        selected: selected,
        onSelected: (_) => onTap(),
        selectedColor: color,
        backgroundColor: scheme.surface,
        labelStyle: TextStyle(
          fontWeight: FontWeight.w700,
          color: selected ? Colors.white : scheme.onSurface,
        ),
        side: BorderSide(color: selected ? color : scheme.outlineVariant),
      ),
    );
  }
}
