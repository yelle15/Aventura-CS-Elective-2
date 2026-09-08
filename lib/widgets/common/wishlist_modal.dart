import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/product.dart';
import '../../theme/app_theme.dart';

void showWishlistModal(BuildContext context, Product product, bool isAdded) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
    barrierColor: Theme.of(context).colorScheme.scrim.withValues(alpha: 0.15),
    isScrollControlled: false,
    builder: (modalContext) {
      final colors = Theme.of(modalContext).colorScheme;

      // Auto dismiss modal sheet after 2.5 seconds
      Timer(const Duration(milliseconds: 2500), () {
        if (Navigator.of(modalContext).canPop()) {
          Navigator.of(modalContext).pop();
        }
      });

      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colors.outline.withValues(alpha: 0.35),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.25),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isAdded
                      ? AppTheme.red.withValues(alpha: 0.15)
                      : colors.outline.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isAdded
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_remove_rounded,
                  color: isAdded ? colors.primary : colors.outline,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAdded ? 'Added to Wishlist' : 'Removed from Wishlist',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: colors.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isAdded)
                TextButton(
                  onPressed: () {
                    Navigator.of(modalContext).pop();
                    context.go('/wishlist');
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.red,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  child: const Text(
                    'VIEW',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}
