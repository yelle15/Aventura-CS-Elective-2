import 'package:flutter/material.dart';

class SpinningPokeball extends StatefulWidget {
  const SpinningPokeball({super.key, this.size = 56});

  final double size;

  @override
  State<SpinningPokeball> createState() => _SpinningPokeballState();
}

class _SpinningPokeballState extends State<SpinningPokeball>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: RotationTransition(
        turns: _controller,
        child: Image.asset(
          'assets/images/pokeball.png',
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.catching_pokemon,
            size: widget.size,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key, this.message = 'Catching Pokémon...'});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SpinningPokeball(size: 64),
              const SizedBox(height: 16),
              Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({super.key, required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _MessageView(
      icon: Icons.wifi_off_rounded,
      title: 'Something went wrong',
      message: message,
      onRetry: onRetry,
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return _MessageView(
      icon: Icons.catching_pokemon,
      title: 'No Pokémon found',
      message: 'The PokéAPI returned an empty list.',
      onRetry: onRetry,
    );
  }
}

class NoMatchesView extends StatelessWidget {
  const NoMatchesView({super.key, required this.onClear});

  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return _MessageView(
      icon: Icons.search_off_rounded,
      title: 'No matches',
      message: 'No Pokémon match your search and filters.',
      onRetry: onClear,
      buttonLabel: 'Clear filters',
      buttonIcon: Icons.filter_alt_off_rounded,
    );
  }
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    required this.message,
    required this.onRetry,
    this.buttonLabel = 'Try again',
    this.buttonIcon = Icons.refresh,
  });

  final String buttonLabel;
  final IconData buttonIcon;
  final IconData icon;
  final String title;
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Card(
        margin: const EdgeInsets.all(24),
        child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: Icon(buttonIcon),
              label: Text(buttonLabel),
            ),
          ],
        ),
        ),
      ),
    );
  }
}
