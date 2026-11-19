import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/formatters.dart';
import '../models/product.dart';
import '../providers/product_providers.dart';
import '../theme/app_theme.dart';
import 'product_image.dart';

class FeaturedCarousel extends ConsumerStatefulWidget {
  const FeaturedCarousel({super.key});

  @override
  ConsumerState<FeaturedCarousel> createState() => _FeaturedCarouselState();
}

class _FeaturedCarouselState extends ConsumerState<FeaturedCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.88);
  Timer? _timer;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients) return;
      final count = ref.read(featuredProductsProvider).value?.length ?? 0;
      if (count < 2) return;
      _goTo((_currentIndex + 1) % count);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int index) {
    if (!_pageController.hasClients) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ref.watch(featuredProductsProvider).when(
          skipLoadingOnReload: true,
          loading: () => _frame(
            context,
            const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
          error: (error, _) => _frame(
            context,
            Row(
              children: [
                const Icon(Icons.error_outline_rounded),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text('Could not load featured products.'),
                ),
                TextButton(
                  onPressed: () => ref.invalidate(featuredProductsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (featured) => featured.isEmpty
              ? const SizedBox.shrink()
              : _buildCarousel(context, featured),
        );
  }

  Widget _frame(BuildContext context, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Featured',
          style: AppTheme.display(
            fontSize: 28,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildCarousel(BuildContext context, List<Product> featured) {
    final colors = Theme.of(context).colorScheme;
    final selected = _currentIndex.clamp(0, featured.length - 1);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          'Featured',
          style: AppTheme.display(fontSize: 28, color: colors.onSurface),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 200,
          child: PageView.builder(
            controller: _pageController,
            padEnds: false,
            itemCount: featured.length,
            onPageChanged: (index) => setState(() => _currentIndex = index),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(right: 12),
              child: _FeaturedCard(product: featured[index], index: index),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < featured.length; i++)
                GestureDetector(
                  onTap: () => _goTo(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: i == selected ? 18 : 6,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      color: i == selected
                          ? AppTheme.red
                          : colors.onSurfaceVariant.withAlpha(110),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.product, required this.index});

  final Product product;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Colors.white.withAlpha(35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(child: _TieDyeBackground(seed: index)),
          InkWell(
            onTap: () => context.go('/product/${product.id}', extra: product),
            splashColor: Colors.white.withAlpha(30),
            child: Row(
              children: [
                Expanded(
                  flex: 5,
                  child: ClipRect(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: ProductImage(url: product.imageUrl),
                    ),
                  ),
                ),
                Expanded(
                  flex: 6,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4, 16, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          product.categoryName.toUpperCase(),
                          style: TextStyle(
                            color: Colors.white.withAlpha(200),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.1,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          product.name,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            height: 1.2,
                            shadows: const [
                              Shadow(color: Colors.black45, blurRadius: 6),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          formatPeso(product.price),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TieDyeBackground extends StatelessWidget {
  const _TieDyeBackground({required this.seed});

  final int seed;

  static const _layouts = [
    [Alignment(-0.9, -0.8), Alignment(0.8, 0.9), Alignment(0.7, -0.9)],
    [Alignment(0.9, -0.7), Alignment(-0.8, 0.9), Alignment(-0.1, -0.3)],
    [Alignment(-0.4, 0.9), Alignment(0.9, 0.1), Alignment(-0.9, -0.9)],
    [Alignment(0.2, -0.9), Alignment(-0.9, 0.3), Alignment(0.9, 0.9)],
  ];

  static const _crimson = Color(0xFFB0102A);
  static const _ember = Color(0xFFFF6B4A);

  @override
  Widget build(BuildContext context) {
    final spots = _layouts[seed % _layouts.length];
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF4A0710), Color(0xFF14080A)],
            ),
          ),
        ),
        _blob(spots[0], AppTheme.red, 1.0),
        _blob(spots[1], _crimson, 0.9),
        _blob(spots[2], _ember, 0.55),
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
