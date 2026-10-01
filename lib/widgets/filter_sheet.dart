import 'package:flutter/material.dart';

import '../models/pokemon.dart';
import '../models/pokemon_details.dart';
import '../models/pokemon_filter.dart';

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key, required this.initial, required this.allDetails});

  final PokemonFilter initial;
  final Future<Map<int, PokemonDetails?>> allDetails;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  late PokemonFilter _filter = widget.initial;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 8, 0),
          child: Row(
            children: [
              Expanded(
                child: Text('Filters', style: theme.textTheme.titleLarge),
              ),
              TextButton(
                onPressed: () =>
                    setState(() => _filter = _filter.clearSheetFilters()),
                child: const Text('Clear all'),
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<Map<int, PokemonDetails?>>(
            future: widget.allDetails,
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return const Center(child: CircularProgressIndicator());
              }
              final loaded =
                  (snapshot.data ?? const {}).values.whereType<PokemonDetails>().toList();
              if (loaded.isEmpty) {
                return const Center(
                  child: Text('Pokédex data could not be loaded.'),
                );
              }
              return _options(loaded);
            },
          ),
        ),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.pop(context, _filter),
                child: const Text('Show results'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _options(List<PokemonDetails> loaded) {
    final generations = {for (final d in loaded) d.generation}.toList()..sort();
    final abilities = {
      for (final d in loaded)
        for (final a in d.abilities) a.name,
    }.toList()
      ..sort();
    final heights = loaded.map((d) => d.heightM).toList()..sort();
    final weights = loaded.map((d) => d.weightKg).toList()..sort();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const _Heading('Generation'),
        Wrap(
          spacing: 6,
          children: [
            _choice('Any', _filter.generation == null,
                () => _filter.copyWith(generation: null)),
            for (final g in generations)
              _choice(
                PokemonDetails.generationLabelFor(g),
                _filter.generation == g,
                () => _filter.copyWith(generation: g),
              ),
          ],
        ),
        const _Heading('Evolution stage'),
        Wrap(
          spacing: 6,
          children: [
            _choice('Any', _filter.stage == null,
                () => _filter.copyWith(stage: null)),
            for (final s in const ['BASIC', 'STAGE 1', 'STAGE 2'])
              _choice(
                prettify(s.toLowerCase().replaceAll(' ', '-')),
                _filter.stage == s,
                () => _filter.copyWith(stage: s),
              ),
          ],
        ),
        const _Heading('Legendary / Mythical'),
        Wrap(
          spacing: 6,
          children: [
            for (final r in Rarity.values)
              _choice(
                switch (r) {
                  Rarity.any => 'Any',
                  Rarity.legendary => 'Legendary',
                  Rarity.mythical => 'Mythical',
                  Rarity.regular => 'Regular',
                },
                _filter.rarity == r,
                () => _filter.copyWith(rarity: r),
              ),
          ],
        ),
        const _Heading('Ability'),
        DropdownButtonFormField<String?>(
          key: ValueKey(_filter.ability),
          initialValue: _filter.ability,
          isExpanded: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: [
            const DropdownMenuItem(value: null, child: Text('Any ability')),
            for (final a in abilities)
              DropdownMenuItem(value: a, child: Text(prettify(a))),
          ],
          onChanged: (value) =>
              setState(() => _filter = _filter.copyWith(ability: value)),
        ),
        _rangeSection(
          title: 'Height',
          unit: 'm',
          lo: heights.first,
          hi: heights.last,
          min: _filter.minHeight,
          max: _filter.maxHeight,
          onChanged: (min, max) =>
              _filter.copyWith(minHeight: min, maxHeight: max),
        ),
        _rangeSection(
          title: 'Weight',
          unit: 'kg',
          lo: weights.first,
          hi: weights.last,
          min: _filter.minWeight,
          max: _filter.maxWeight,
          onChanged: (min, max) =>
              _filter.copyWith(minWeight: min, maxWeight: max),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _choice(String label, bool selected, PokemonFilter Function() next) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => setState(() => _filter = next()),
    );
  }

  Widget _rangeSection({
    required String title,
    required String unit,
    required double lo,
    required double hi,
    required double? min,
    required double? max,
    required PokemonFilter Function(double? min, double? max) onChanged,
  }) {
    if (lo >= hi) return const SizedBox.shrink();
    final values = RangeValues(min ?? lo, max ?? hi);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Heading(
          '$title: ${values.start.toStringAsFixed(1)} – '
          '${values.end.toStringAsFixed(1)} $unit',
        ),
        RangeSlider(
          values: values,
          min: lo,
          max: hi,
          onChanged: (v) => setState(() {
            _filter = onChanged(
              v.start <= lo ? null : v.start,
              v.end >= hi ? null : v.end,
            );
          }),
        ),
      ],
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 6),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
