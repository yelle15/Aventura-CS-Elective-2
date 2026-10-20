import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../models/pokemon_details.dart';
import '../models/pokemon_filter.dart';
import '../providers/filter_provider.dart';
import '../providers/pokemon_details_provider.dart';
import 'state_views.dart';

class FilterSheet extends ConsumerWidget {
  const FilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final draft = ref.watch(filterDraftProvider);
    final details = ref.watch(pokemonDetailsProvider);

    final Widget body;
    if (details.isLoading) {
      body = const Center(child: SpinningPokeball(size: 44));
    } else if (details.loaded.isEmpty) {
      body = const Center(child: Text('Pokédex data could not be loaded.'));
    } else {
      body = _options(ref, draft, details.all);
    }

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
                onPressed: () => ref
                    .read(filterDraftProvider.notifier)
                    .edit((d) => d.clearSheetFilters()),
                child: const Text('Clear all'),
              ),
            ],
          ),
        ),
        Expanded(child: body),
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  ref.read(filterDraftProvider.notifier).apply();
                  Navigator.pop(context);
                },
                child: const Text('Show results'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _options(
    WidgetRef ref,
    PokemonFilter draft,
    List<PokemonDetails> loaded,
  ) {
    final generations = {for (final d in loaded) d.generation}.toList()..sort();
    final abilities = {
      for (final d in loaded)
        for (final a in d.abilities) a.name,
    }.toList()..sort();
    final heights = loaded.map((d) => d.heightM).toList()..sort();
    final weights = loaded.map((d) => d.weightKg).toList()..sort();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        const _Heading('Generation'),
        Wrap(
          spacing: 6,
          children: [
            _choice(
              ref,
              'Any',
              draft.generation == null,
              () => draft.copyWith(generation: null),
            ),
            for (final g in generations)
              _choice(
                ref,
                PokemonDetails.generationLabelFor(g),
                draft.generation == g,
                () => draft.copyWith(generation: g),
              ),
          ],
        ),
        const _Heading('Evolution stage'),
        Wrap(
          spacing: 6,
          children: [
            _choice(
              ref,
              'Any',
              draft.stage == null,
              () => draft.copyWith(stage: null),
            ),
            for (final s in const ['BASIC', 'STAGE 1', 'STAGE 2'])
              _choice(
                ref,
                prettify(s.toLowerCase().replaceAll(' ', '-')),
                draft.stage == s,
                () => draft.copyWith(stage: s),
              ),
          ],
        ),
        const _Heading('Legendary / Mythical'),
        Wrap(
          spacing: 6,
          children: [
            for (final r in Rarity.values)
              _choice(
                ref,
                switch (r) {
                  Rarity.any => 'Any',
                  Rarity.legendary => 'Legendary',
                  Rarity.mythical => 'Mythical',
                  Rarity.regular => 'Regular',
                },
                draft.rarity == r,
                () => draft.copyWith(rarity: r),
              ),
          ],
        ),
        const _Heading('Ability'),
        DropdownButtonFormField<String?>(
          key: ValueKey(draft.ability),
          initialValue: draft.ability,
          isExpanded: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
          items: [
            const DropdownMenuItem(value: null, child: Text('Any ability')),
            for (final a in abilities)
              DropdownMenuItem(value: a, child: Text(prettify(a))),
          ],
          onChanged: (value) => ref
              .read(filterDraftProvider.notifier)
              .edit((d) => d.copyWith(ability: value)),
        ),
        _rangeSection(
          ref: ref,
          title: 'Height',
          unit: 'm',
          lo: heights.first,
          hi: heights.last,
          min: draft.minHeight,
          max: draft.maxHeight,
          onChanged: (min, max) =>
              draft.copyWith(minHeight: min, maxHeight: max),
        ),
        _rangeSection(
          ref: ref,
          title: 'Weight',
          unit: 'kg',
          lo: weights.first,
          hi: weights.last,
          min: draft.minWeight,
          max: draft.maxWeight,
          onChanged: (min, max) =>
              draft.copyWith(minWeight: min, maxWeight: max),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _choice(
    WidgetRef ref,
    String label,
    bool selected,
    PokemonFilter Function() next,
  ) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) =>
          ref.read(filterDraftProvider.notifier).edit((_) => next()),
    );
  }

  Widget _rangeSection({
    required WidgetRef ref,
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
          onChanged: (v) => ref.read(filterDraftProvider.notifier).edit(
            (_) => onChanged(
              v.start <= lo ? null : v.start,
              v.end >= hi ? null : v.end,
            ),
          ),
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
        style: Theme.of(
          context,
        ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}
