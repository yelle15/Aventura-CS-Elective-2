import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../models/pokemon_filter.dart';
import 'card_palette.dart';

/// Search field, filter button, and a scrollable row of type chips.
class SearchFilterBar extends StatelessWidget {
  const SearchFilterBar({
    super.key,
    required this.controller,
    required this.filter,
    required this.onChanged,
    required this.onOpenFilters,
  });

  final TextEditingController controller;
  final PokemonFilter filter;
  final ValueChanged<PokemonFilter> onChanged;
  final VoidCallback onOpenFilters;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final count = filter.sheetFilterCount;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.search,
                  onChanged: (text) => onChanged(filter.copyWith(query: text)),
                  decoration: InputDecoration(
                    hintText: 'Search Pokémon by name or number...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: filter.query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () {
                              controller.clear();
                              onChanged(filter.copyWith(query: ''));
                            },
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
                  onPressed: onOpenFilters,
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
                  label: 'All',
                  selected: filter.type == null,
                  onTap: () => onChanged(filter.copyWith(type: null)),
                ),
                for (final type in CardPalette.types)
                  _TypeChip(
                    label: prettify(type),
                    type: type,
                    selected: filter.type == type,
                    onTap: () => onChanged(
                      filter.copyWith(type: filter.type == type ? null : type),
                    ),
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
