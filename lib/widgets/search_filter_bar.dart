import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/pokemon.dart';
import '../providers/pokedex_provider.dart';
import 'card_palette.dart';
import 'filter_sheet.dart';

class SearchFilterBar extends StatefulWidget {
  const SearchFilterBar({super.key});

  @override
  State<SearchFilterBar> createState() => _SearchFilterBarState();
}

class _SearchFilterBarState extends State<SearchFilterBar> {
  late final PokedexProvider _pokedex;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _pokedex = context.read<PokedexProvider>();
    _controller = TextEditingController(text: _pokedex.filter.query);
    _pokedex.addListener(_syncQuery);
  }

  void _syncQuery() {
    final query = _pokedex.filter.query;
    if (_controller.text != query) _controller.text = query;
  }

  @override
  void dispose() {
    _pokedex.removeListener(_syncQuery);
    _controller.dispose();
    super.dispose();
  }

  void _openFilterSheet() {
    context.read<PokedexProvider>().startFilterDraft();
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
    final scheme = Theme.of(context).colorScheme;
    final filter = context.watch<PokedexProvider>().filter;
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
                  onChanged: (text) => context
                      .read<PokedexProvider>()
                      .updateFilter((f) => f.copyWith(query: text)),
                  decoration: InputDecoration(
                    hintText: 'Search Pokémon by name or number...',
                    prefixIcon: const Icon(Icons.search_rounded),
                    suffixIcon: filter.query.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Clear search',
                            icon: const Icon(Icons.close_rounded),
                            onPressed: () => context
                                .read<PokedexProvider>()
                                .updateFilter((f) => f.copyWith(query: '')),
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
                  label: 'All',
                  selected: filter.type == null,
                  onTap: () => context
                      .read<PokedexProvider>()
                      .updateFilter((f) => f.copyWith(type: null)),
                ),
                for (final type in CardPalette.types)
                  _TypeChip(
                    label: prettify(type),
                    type: type,
                    selected: filter.type == type,
                    onTap: () => context.read<PokedexProvider>().updateFilter(
                          (f) =>
                              f.copyWith(type: f.type == type ? null : type),
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
