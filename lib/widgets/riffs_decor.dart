import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class TieDyeBackground extends StatelessWidget {
  const TieDyeBackground({super.key, required this.seed});

  final int seed;

  static const _layouts = [
    [Alignment(-0.9, -0.8), Alignment(0.8, 0.9), Alignment(0.7, -0.9)],
    [Alignment(0.9, -0.7), Alignment(-0.8, 0.9), Alignment(-0.1, -0.3)],
    [Alignment(-0.4, 0.9), Alignment(0.9, 0.1), Alignment(-0.9, -0.9)],
    [Alignment(0.2, -0.9), Alignment(-0.9, 0.3), Alignment(0.9, 0.9)],
  ];

  @override
  Widget build(BuildContext context) {
    final spots = _layouts[seed.abs() % _layouts.length];
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(gradient: AppTheme.nightGradient),
        ),
        _blob(spots[0], AppTheme.red, 1.0),
        _blob(spots[1], AppTheme.crimson, 0.9),
        _blob(spots[2], AppTheme.ember, 0.55),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: spots[0],
              radius: 0.16,
              colors: [Colors.white.withAlpha(0), Colors.white.withAlpha(22)],
              tileMode: TileMode.mirror,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.black.withAlpha(0), Colors.black.withAlpha(120)],
              stops: const [0.35, 1],
            ),
          ),
        ),
      ],
    );
  }

  Widget _blob(Alignment center, Color color, double radius) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: center,
          radius: radius,
          colors: [color.withAlpha(235), color.withAlpha(0)],
        ),
      ),
    );
  }
}

class BannerBackground extends StatelessWidget {
  const BannerBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppTheme.night, AppTheme.wine, AppTheme.crimson],
              stops: [0.0, 0.55, 1.0],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.75, -0.1),
              radius: 0.85,
              colors: [AppTheme.red.withAlpha(230), AppTheme.red.withAlpha(0)],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(1.0, 1.0),
              radius: 0.6,
              colors: [AppTheme.ember.withAlpha(150), AppTheme.ember.withAlpha(0)],
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0.75, -0.1),
              radius: 0.18,
              colors: [Colors.white.withAlpha(0), Colors.white.withAlpha(18)],
              tileMode: TileMode.mirror,
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Colors.black.withAlpha(150), Colors.black.withAlpha(0)],
              stops: const [0.0, 0.6],
            ),
          ),
        ),
      ],
    );
  }
}

class ImageGlow extends StatelessWidget {
  const ImageGlow({
    super.key,
    required this.child,
    this.radius = 18,
    this.padding = const EdgeInsets.all(12),
  });

  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final isDark = AppTheme.isDark(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: RadialGradient(
          center: const Alignment(0, 0.3),
          radius: 0.95,
          colors: isDark
              ? [AppTheme.red.withAlpha(70), AppTheme.backgroundSecondary]
              : [AppTheme.red.withAlpha(36), AppTheme.lightPanel],
        ),
      ),
      child: child,
    );
  }
}

class GradientFill extends StatelessWidget {
  const GradientFill({
    super.key,
    required this.child,
    this.enabled = true,
    this.radius = 16,
  });

  final Widget child;
  final bool enabled;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(radius),
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppTheme.redGradient,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: AppTheme.redGlow(alpha: 60),
      ),
      child: FilledButtonTheme(
        data: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: shape,
          ).merge(Theme.of(context).filledButtonTheme.style),
        ),
        child: child,
      ),
    );
  }
}

class InitialsAvatar extends StatelessWidget {
  const InitialsAvatar({super.key, required this.name, this.size = 42});

  final String name;
  final double size;

  String get _initials {
    final parts = name
        .split(RegExp(r'[\s@._-]+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (parts.isEmpty) return 'R';
    final letters = parts.take(2).map((part) => part[0].toUpperCase());
    return letters.join();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppTheme.redGradient,
        boxShadow: AppTheme.redGlow(alpha: 50),
      ),
      child: Text(
        _initials,
        style: AppTheme.display(fontSize: size * 0.4, color: Colors.white),
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.onDark = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      style: IconButton.styleFrom(
        fixedSize: const Size(44, 44),
        foregroundColor: onDark ? Colors.white : null,
        backgroundColor:
            onDark ? Colors.white.withAlpha(28) : AppTheme.panel(context),
        side: BorderSide(
          color: onDark ? Colors.white.withAlpha(60) : AppTheme.outline(context),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    super.key,
    required this.title,
    this.textKey,
    this.trailing,
  });

  final String title;
  final Key? textKey;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 5,
          height: 24,
          decoration: BoxDecoration(
            gradient: AppTheme.redGradient,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            key: textKey,
            style: AppTheme.display(
              fontSize: 26,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class TagPill extends StatelessWidget {
  const TagPill({super.key, required this.text, this.onDark = false});

  final String text;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: onDark
            ? Colors.black.withAlpha(120)
            : AppTheme.panel(context).withAlpha(230),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: onDark ? Colors.white.withAlpha(40) : AppTheme.outline(context),
        ),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: onDark ? Colors.white : AppTheme.red,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
        ),
      ),
    );
  }
}
