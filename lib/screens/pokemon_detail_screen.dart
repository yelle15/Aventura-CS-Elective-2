import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/pokemon.dart';
import '../models/pokemon_details.dart';
import '../providers/nickname_provider.dart';
import '../providers/pokemon_details_provider.dart';
import '../providers/selected_pokemon_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_bar_actions.dart';
import '../widgets/card_palette.dart';
import '../widgets/favorite_heart.dart';
import '../widgets/favorites_panel.dart';
import '../widgets/nickname_editor.dart';
import '../widgets/pokemon_card.dart' show pokemonHeroTag;
import '../widgets/state_views.dart';

void openPokemonDetails(BuildContext context, WidgetRef ref, Pokemon pokemon) {
  ref.read(selectedPokemonProvider.notifier).select(pokemon);
  Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const PokemonDetailScreen()),
  );
}

class PokemonDetailScreen extends ConsumerWidget {
  const PokemonDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemon = ref.watch(selectedPokemonProvider);
    final nickname = ref.watch(
      nicknameProvider.select((n) => pokemon == null ? null : n[pokemon.id]),
    );
    final brightness = Theme.of(context).brightness;

    return Scaffold(
      appBar: AppBar(
        title: Text(nickname ?? pokemon?.displayName ?? 'Pokédex'),
        actions: [
          if (pokemon != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FavoriteHeart(pokemon: pokemon, size: 20),
            ),
          const ThemeButton(),
        ],
      ),
      body: DecoratedBox(
        decoration: BoxDecoration(gradient: AppTheme.backgroundFor(brightness)),
        child: FavoritesPanel(
          openDetailsOnTap: false,
          child: pokemon == null
              ? const Center(child: Text('No Pokémon selected.'))
              : const _DetailContent(),
        ),
      ),
      floatingActionButton: const FavoritesFab(),
    );
  }
}

class _DetailContent extends StatelessWidget {
  const _DetailContent();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
          children: const [
            _ArtCard(),
            SizedBox(height: 12),
            _NicknameCard(),
            SizedBox(height: 12),
            _InfoSection(),
          ],
        ),
      ),
    );
  }
}

class _ArtCard extends ConsumerWidget {
  const _ArtCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemon = ref.watch(selectedPokemonProvider)!;
    final details = ref.watch(
      pokemonDetailsProvider.select((s) => s.loaded[pokemon.id]),
    );
    final theme = Theme.of(context);
    final tint = CardPalette.forSpecies(details?.colorName);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            height: 260,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(tint, Colors.white, 0.75)!,
                  Color.lerp(tint, Colors.white, 0.25)!,
                ],
              ),
            ),
            child: Hero(
              tag: pokemonHeroTag(pokemon.id),
              child: Image.network(
                pokemon.imageUrl,
                fit: BoxFit.contain,
                semanticLabel: pokemon.displayName,
                loadingBuilder: (context, child, progress) => progress == null
                    ? child
                    : const Center(child: SpinningPokeball(size: 48)),
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.catching_pokemon, size: 96),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              children: [
                Text(
                  pokemon.formattedId,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.outline,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  pokemon.displayName,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                if (details != null) ...[
                  const SizedBox(height: 4),
                  Text(details.genus),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    alignment: WrapAlignment.center,
                    children: [
                      for (final type in details.types)
                        Chip(
                          avatar: EnergyIcon(type: type, size: 18),
                          label: Text(prettify(type)),
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                          backgroundColor: CardPalette.forType(type),
                          side: BorderSide.none,
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NicknameCard extends ConsumerWidget {
  const _NicknameCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pokemon = ref.watch(selectedPokemonProvider)!;
    final nickname = ref.watch(
      nicknameProvider.select((nicknames) => nicknames[pokemon.id]),
    );
    final theme = Theme.of(context);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        leading: const Icon(Icons.badge_outlined),
        title: Text(
          nickname == null ? 'No nickname yet' : '“$nickname”',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontStyle: nickname == null ? FontStyle.normal : FontStyle.italic,
          ),
        ),
        subtitle: Text('Original name: ${pokemon.displayName}'),
        trailing: FilledButton.tonalIcon(
          onPressed: () => showNicknameEditor(context),
          icon: Icon(nickname == null ? Icons.add_rounded : Icons.edit_rounded),
          label: Text(nickname == null ? 'Add' : 'Edit'),
        ),
      ),
    );
  }
}

class _InfoSection extends ConsumerWidget {
  const _InfoSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final id = ref.watch(selectedPokemonProvider)!.id;
    final details = ref.watch(
      pokemonDetailsProvider.select((s) => s.loaded[id]),
    );
    final failed = ref.watch(
      pokemonDetailsProvider.select((s) => s.failed.contains(id)),
    );

    if (details != null) return _DetailsCard(details: details);

    if (failed) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text('Card details could not be loaded.'),
              const SizedBox(height: 8),
              FilledButton.icon(
                onPressed: () =>
                    ref.read(pokemonDetailsProvider.notifier).retry(id),
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ],
          ),
        ),
      );
    }

    return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: SpinningPokeball(size: 40)),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  const _DetailsCard({required this.details});

  final PokemonDetails details;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final heading = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w800,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (details.flavorText.isNotEmpty) ...[
              Text(
                details.flavorText,
                style: const TextStyle(fontStyle: FontStyle.italic),
              ),
              const SizedBox(height: 16),
            ],
            Row(
              children: [
                _Fact(label: 'Height', value: '${details.heightM} m'),
                _Fact(label: 'Weight', value: '${details.weightKg} kg'),
                _Fact(label: 'Gen', value: details.generationLabel),
                _Fact(
                  label: 'Stage',
                  value: prettify(details.stage.toLowerCase()),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text('Base stats', style: heading),
            const SizedBox(height: 8),
            for (final stat in details.stats) _StatBar(stat: stat),
            const SizedBox(height: 16),
            Text('Abilities', style: heading),
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final a in details.abilities)
                  Chip(
                    label: Text(
                      a.isHidden ? '${a.displayName} (hidden)' : a.displayName,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatBar extends StatelessWidget {
  const _StatBar({required this.stat});

  final PokemonStat stat;

  static const double _max = 255;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          SizedBox(
            width: 56,
            child: Text(
              stat.shortLabel,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          SizedBox(width: 32, child: Text('${stat.value}')),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (stat.value / _max).clamp(0.0, 1.0),
                minHeight: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
