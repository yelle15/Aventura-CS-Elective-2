import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({
    super.key,
    required this.path,
    this.iconSize = 54,
    this.scale = 1,
    this.placeholderOnly = false,
    this.showPlaceholder = true,
  });

  final String path;
  final double iconSize;
  final double scale;
  final bool placeholderOnly;
  final bool showPlaceholder;

  @override
  Widget build(BuildContext context) {
    final placeholder = Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.music_note_rounded,
        size: iconSize,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
    final fallback = showPlaceholder
        ? placeholder
        : Image.asset(
            'assets/images/hero_guitar.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.expand(),
          );
    if (placeholderOnly) return placeholder;

    return Transform.scale(
      scale: scale,
      child: Image.asset(
        path,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }
}

class HeroImagePlaceholder extends StatelessWidget {
  const HeroImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) =>
      const ProductImage(path: 'assets/images/hero_guitar.png', iconSize: 110);
}
