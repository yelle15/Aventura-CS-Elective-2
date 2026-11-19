import 'package:flutter/material.dart';

class ProductImage extends StatelessWidget {
  const ProductImage({super.key, required this.url, this.iconSize = 48});

  final String? url;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final placeholder = Center(
      child: Icon(
        Icons.music_note_rounded,
        size: iconSize,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
    final source = url;
    if (source == null || source.isEmpty) return placeholder;

    if (source.startsWith('assets/')) {
      return Image.asset(
        source,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => placeholder,
      );
    }

    return Image.network(
      source,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      errorBuilder: (context, error, stackTrace) => placeholder,
    );
  }
}
