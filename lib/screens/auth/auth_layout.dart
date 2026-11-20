import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';
import '../../widgets/riffs_decor.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({super.key, required this.subtitle, required this.child});

  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _AuthHero(),
                  const SizedBox(height: 26),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: AppTheme.display(
                      fontSize: 28,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Guitars and basses for every sound.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 22),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthHero extends StatelessWidget {
  const _AuthHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withAlpha(28)),
        boxShadow: AppTheme.redGlow(alpha: 50),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          const Positioned.fill(child: BannerBackground()),
          Positioned(
            right: -6,
            top: 8,
            bottom: 8,
            width: 160,
            child: Transform.rotate(
              angle: -0.32,
              child: Image.asset(
                'assets/images/products/stratocaster_skywing.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                  Icons.music_note_rounded,
                  size: 110,
                  color: Colors.white.withAlpha(70),
                ),
              ),
            ),
          ),
          Positioned(
            left: 24,
            bottom: 22,
            right: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'RIFFS',
                    style: GoogleFonts.protestRevolution(
                      color: AppTheme.red,
                      fontSize: 56,
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'FIND YOUR SOUND',
                  style: AppTheme.display(fontSize: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class AuthMessage extends StatelessWidget {
  const AuthMessage({super.key, required this.text, this.isError = false});

  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    final color =
        isError ? Theme.of(context).colorScheme.error : AppTheme.success;
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(110)),
      ),
      child: Text(text, style: TextStyle(color: color)),
    );
  }
}

class SocialSignInButtons extends StatelessWidget {
  const SocialSignInButtons({
    super.key,
    required this.enabled,
    required this.onGoogle,
  });

  final bool enabled;
  final VoidCallback onGoogle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'or continue with',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 52,
          child: OutlinedButton.icon(
            onPressed: enabled ? onGoogle : null,
            style: OutlinedButton.styleFrom(
              backgroundColor: AppTheme.panel(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            icon: Container(
              width: 26,
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.lightBorder),
              ),
              child: const Text(
                'G',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  color: AppTheme.red,
                ),
              ),
            ),
            label: const Text('Continue with Google'),
          ),
        ),
      ],
    );
  }
}

String? validateEmail(String? value) {
  final text = value?.trim() ?? '';
  final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text);
  return valid ? null : 'Enter a valid email address';
}
