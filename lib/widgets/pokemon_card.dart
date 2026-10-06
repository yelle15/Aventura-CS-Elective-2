import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../models/pokemon.dart';
import '../models/pokemon_details.dart';
import '../providers/pokedex_provider.dart';
import '../screens/pokemon_detail_screen.dart';
import 'card_palette.dart';
import 'state_views.dart';

class PokemonCard extends StatelessWidget {
  const PokemonCard({super.key, required this.pokemon});

  final Pokemon pokemon;

  static const Size designSize = Size(250, 350);

  void _openDetails(BuildContext context) {
    context.read<PokedexProvider>().selectPokemon(pokemon);
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const PokemonDetailScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (details, failed) =
        context.select<PokedexProvider, (PokemonDetails?, bool)>(
      (p) => (p.detailsFor(pokemon.id), p.detailsFailed(pokemon.id)),
    );

    return Semantics(
      button: true,
      label: 'Open ${pokemon.displayName}',
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => _openDetails(context),
          child: FittedBox(
            child: SizedBox.fromSize(
              size: designSize,
              child: _CardFace(
                pokemon: pokemon,
                details: details,
                failed: failed,
                onRetry: () =>
                    context.read<PokedexProvider>().retryDetails(pokemon.id),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String pokemonHeroTag(int id) => 'pokemon-art-$id';

class _CardFace extends StatelessWidget {
  const _CardFace({
    required this.pokemon,
    required this.details,
    required this.failed,
    required this.onRetry,
  });

  final Pokemon pokemon;
  final PokemonDetails? details;
  final bool failed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseTint = CardPalette.forSpecies(details?.colorName);

    final tint = isDark
        ? Color.lerp(baseTint, const Color(0xFF162032), 0.45)!
        : baseTint;
    final highlight = isDark
        ? Color.lerp(tint, const Color(0xFF2C3C54), 0.5)!
        : Color.lerp(tint, Colors.white, 0.55)!;

    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF121A26) : CardPalette.border,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x66000000) : const Color(0x33000000),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        padding: const EdgeInsets.fromLTRB(7, 6, 7, 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(9),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [highlight, tint, highlight, tint],
            stops: const [0, 0.35, 0.6, 1],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _Header(pokemon: pokemon, details: details),
            const SizedBox(height: 4),
            _ArtWindow(pokemon: pokemon, tint: tint),
            _InfoStrip(pokemon: pokemon, details: details),
            const SizedBox(height: 5),
            Expanded(
              child: _AttackPanel(
                details: details,
                failed: failed,
                onRetry: onRetry,
              ),
            ),
            const SizedBox(height: 5),
            _MatchupStrip(details: details),
            const SizedBox(height: 4),
            _Footer(details: details),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.pokemon, required this.details});

  final Pokemon pokemon;
  final PokemonDetails? details;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final d = details;

    return SizedBox(
      height: 34,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              gradient: LinearGradient(
                colors: isDark
                    ? const [Color(0xFF2A374A), Color(0xFF1C2634)]
                    : const [Color(0xFFF4F5F7), Color(0xFFB9BEC7)],
              ),
            ),
            child: Text(
              d?.stage ?? 'BASIC',
              style: TextStyle(
                fontSize: 6.5,
                fontWeight: FontWeight.w900,
                fontStyle: FontStyle.italic,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF4A5260),
              ),
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  pokemon.displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.05,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : CardPalette.ink,
                  ),
                ),
                Text(
                  d == null ? ' ' : d.genus.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 5.5,
                    letterSpacing: 0.8,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF4A5260),
                  ),
                ),
              ],
            ),
          ),
          if (d != null) ...[
            Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'HP',
                    style: TextStyle(fontSize: 7, fontWeight: FontWeight.w900),
                  ),
                  TextSpan(
                    text: '${d.hp}',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              style: TextStyle(color: isDark ? Colors.white : CardPalette.ink),
            ),
            const SizedBox(width: 3),
            EnergyIcon(type: d.mainType, size: 18),
          ],
        ],
      ),
    );
  }
}

class _ArtWindow extends StatelessWidget {
  const _ArtWindow({required this.pokemon, required this.tint});

  final Pokemon pokemon;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 118,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: isDark ? const Color(0xFF384656) : const Color(0xFFCDD2DA),
          width: 2,
        ),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  Color.lerp(tint, const Color(0xFF1E293B), 0.55)!,
                  Color.lerp(tint, const Color(0xFF0F172A), 0.7)!,
                ]
              : [
                  Color.lerp(tint, Colors.white, 0.8)!,
                  Color.lerp(tint, Colors.white, 0.35)!,
                ],
        ),
      ),
      padding: const EdgeInsets.all(6),
      child: Hero(
        tag: pokemonHeroTag(pokemon.id),
        child: Image.network(
          pokemon.imageUrl,
          fit: BoxFit.contain,
          semanticLabel: pokemon.displayName,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return const Center(
              child: SpinningPokeball(size: 24),
            );
          },
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.catching_pokemon,
            size: 48,
            color: isDark ? const Color(0x33FFFFFF) : const Color(0x55000000),
          ),
        ),
      ),
    );
  }
}

class _InfoStrip extends StatelessWidget {
  const _InfoStrip({required this.pokemon, required this.details});

  final Pokemon pokemon;
  final PokemonDetails? details;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final d = details;
    final parts = [
      'No. ${pokemon.formattedId.substring(1)}',
      if (d != null) ...[
        d.genus,
        'Ht. ${d.heightM.toStringAsFixed(1)} m',
        'Wt. ${d.weightKg.toStringAsFixed(1)} kg',
      ],
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(6)),
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF222F42), Color(0xFF1A2433), Color(0xFF222F42)]
              : const [Color(0xFFD5D9E0), Color(0xFFF6F7F9), Color(0xFFD5D9E0)],
        ),
      ),
      child: Text(
        parts.join('  |  '),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 6,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF4A5260),
        ),
      ),
    );
  }
}

class _AttackPanel extends StatelessWidget {
  const _AttackPanel({
    required this.details,
    required this.failed,
    required this.onRetry,
  });

  final PokemonDetails? details;
  final bool failed;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final d = details;

    Widget content;
    if (failed) {
      content = Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Card details unavailable',
              style: TextStyle(
                fontSize: 9,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280),
              ),
            ),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 14),
              label: const Text('Retry', style: TextStyle(fontSize: 10)),
            ),
          ],
        ),
      );
    } else if (d == null) {
      content = const Center(
        child: SpinningPokeball(size: 20),
      );
    } else if (d.attacks.isEmpty) {
      content = Center(
        child: Text(
          'No attacks',
          style: TextStyle(
            fontSize: 9,
            color: isDark ? const Color(0xFF94A3B8) : Colors.black,
          ),
        ),
      );
    } else {
      content = Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [for (final a in d.attacks) _AttackRow(attack: a)],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xE6162132) : const Color(0xF2FFFFFF),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      child: Stack(
        children: [
          Positioned(
            right: -14,
            top: 0,
            bottom: 0,
            child: Icon(
              Icons.catching_pokemon,
              size: 86,
              color: isDark ? const Color(0x14FFFFFF) : const Color(0x0D000000),
            ),
          ),
          Positioned.fill(child: content),
        ],
      ),
    );
  }
}

class _AttackRow extends StatelessWidget {
  const _AttackRow({required this.attack});

  final PokemonAttack attack;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (var i = 0; i < attack.energyCost; i++)
              Padding(
                padding: const EdgeInsets.only(right: 2),
                child: EnergyIcon(
                  type: i == 0 ? attack.type : 'colorless',
                  size: 13,
                ),
              ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                attack.displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : CardPalette.ink,
                ),
              ),
            ),
            if (attack.power != null)
              Text(
                '${attack.power}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: isDark ? Colors.white : CardPalette.ink,
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          attack.effect,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 7,
            height: 1.2,
            color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF2F3742),
          ),
        ),
      ],
    );
  }
}

class _MatchupStrip extends StatelessWidget {
  const _MatchupStrip({required this.details});

  final PokemonDetails? details;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      child: Row(
        children: [
          Expanded(
            child: _Matchup(
              label: 'weakness',
              type: details?.weakness,
              value: '×2',
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _Matchup(
              label: 'resistance',
              type: details?.resistance,
              value: '-30',
            ),
          ),
        ],
      ),
    );
  }
}

class _Matchup extends StatelessWidget {
  const _Matchup({required this.label, required this.type, required this.value});

  final String label;
  final String? type;
  final String value;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final t = type;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: LinearGradient(
          colors: isDark
              ? const [Color(0xFF222F42), Color(0xFF1A2433)]
              : const [Color(0xFFD5D9E0), Color(0xFFF6F7F9)],
        ),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 6.5,
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF4A5260),
            ),
          ),
          const Spacer(),
          if (t != null) ...[
            EnergyIcon(type: t, size: 12),
            const SizedBox(width: 3),
            Text(
              value,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : CardPalette.ink,
              ),
            ),
          ] else
            Text(
              '—',
              style: TextStyle(
                fontSize: 8,
                color: isDark ? const Color(0xFF94A3B8) : Colors.black,
              ),
            ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.details});

  final PokemonDetails? details;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final d = details;

    return SizedBox(
      height: 22,
      child: Row(
        children: [
          Expanded(
            child: Text(
              d?.flavorText ?? '',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 6,
                height: 1.25,
                fontStyle: FontStyle.italic,
                color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF2F3742),
              ),
            ),
          ),
          if (d != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.fromLTRB(2, 2, 6, 2),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xCC162132) : const Color(0xCCFFFFFF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: CardPalette.forType(d.mainType)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EnergyIcon(type: d.mainType, size: 11),
                  const SizedBox(width: 3),
                  Text(
                    d.mainType[0].toUpperCase() + d.mainType.substring(1),
                    style: TextStyle(
                      fontSize: 7,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : CardPalette.ink,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
