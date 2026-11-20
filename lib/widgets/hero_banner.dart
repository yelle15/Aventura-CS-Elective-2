import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/product_providers.dart';
import '../theme/app_theme.dart';
import 'product_image.dart';
import 'riffs_decor.dart';

class HeroBanner extends ConsumerWidget {
  const HeroBanner({
    super.key,
    required this.onShopPressed,
    required this.horizontalPadding,
  });

  final VoidCallback onShopPressed;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final compact = MediaQuery.sizeOf(context).width < 600;
    final placeholder = Icon(
      Icons.music_note_rounded,
      size: compact ? 110 : 160,
      color: Colors.white.withAlpha(70),
    );
    final Widget guitar = ref.watch(featuredProductsProvider).when(
          skipLoadingOnReload: true,
          loading: () => const Center(
            child: SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
          ),
          error: (error, _) => Center(
            child: IconButton(
              tooltip: 'Reload featured guitar',
              onPressed: () => ref.invalidate(featuredProductsProvider),
              icon: Icon(
                Icons.refresh_rounded,
                size: 32,
                color: Colors.white.withAlpha(200),
              ),
            ),
          ),
          data: (featured) {
            final url = featured.isEmpty ? null : featured.first.imageUrl;
            return url == null || url.isEmpty
                ? placeholder
                : ProductImage(url: url, iconSize: 96);
          },
        );

    return SizedBox(
      height: compact ? 224 : 280,
      child: ClipRect(
        child: Stack(
          children: [
            const Positioned.fill(child: BannerBackground()),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1300),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                  child: Stack(
                    children: [
                      Positioned(
                        right: compact ? -10 : 40,
                        top: 14,
                        bottom: 14,
                        width: compact ? 150 : 280,
                        child: Transform.rotate(
                          angle: -0.28,
                          child: guitar,
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: compact ? 210 : 420,
                          ),
                          child: _BannerCopy(
                            compact: compact,
                            onShopPressed: onShopPressed,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerCopy extends StatelessWidget {
  const _BannerCopy({required this.compact, required this.onShopPressed});

  final bool compact;
  final VoidCallback onShopPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'FIND YOUR',
          style: AppTheme.display(
            fontSize: compact ? 26 : 38,
            color: Colors.white,
          ),
        ),
        Text(
          'SOUND',
          style: AppTheme.display(
            fontSize: compact ? 38 : 54,
            color: AppTheme.red,
          ),
        ),
        SizedBox(height: compact ? 6 : 10),
        Text(
          'Find the best guitar and bass for your sound.',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white.withAlpha(200),
            fontSize: compact ? 12.5 : 14,
            height: 1.35,
          ),
        ),
        SizedBox(height: compact ? 14 : 18),
        GradientFill(
          radius: 22,
          child: SizedBox(
            height: compact ? 38 : 44,
            child: FilledButton(
              onPressed: onShopPressed,
              style: FilledButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: compact ? 16 : 22),
                textStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontSize: compact ? 13 : 14,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Shop for guitars'),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
