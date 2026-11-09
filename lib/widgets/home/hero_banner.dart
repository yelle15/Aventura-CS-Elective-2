import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key, required this.onShopPressed});

  final VoidCallback onShopPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 28, 0, 8),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'FIND YOUR',
                textAlign: TextAlign.center,
                style: AppTheme.display(
                  fontSize: 36,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              Text(
                'SOUND',
                textAlign: TextAlign.center,
                style: AppTheme.display(fontSize: 46, color: AppTheme.red),
              ),
              const SizedBox(height: 10),
              Text(
                'Find the best guitar and bass for your sound.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
              ),
              const SizedBox(height: 18),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: onShopPressed,
                  child: const Text('Shop for guitars'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
