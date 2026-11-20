import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/formatters.dart';
import '../models/product.dart';
import '../providers/product_providers.dart';
import '../theme/app_theme.dart';
import 'product_image.dart';
import 'riffs_decor.dart';

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
              height: 210,
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
        const SizedBox(height: 24),
        const SectionTitle(title: 'Featured'),
        const SizedBox(height: 14),
        child,
      ],
    );
  }

  Widget _buildCarousel(BuildContext context, List<Product> featured) {
    final colors = Theme.of(context).colorScheme;
    final selected = _currentIndex.clamp(0, featured.length - 1);

    return _frame(
      context,
      Column(
        children: [
          SizedBox(
            height: 210,
            child: PageView.builder(
              controller: _pageController,
              padEnds: false,
              itemCount: featured.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) => Padding(
                padding: const EdgeInsets.only(right: 14),
                child: _FeaturedCard(product: featured[index], index: index),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < featured.length; i++)
                GestureDetector(
                  onTap: () => _goTo(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: i == selected ? 26 : 8,
                    height: 6,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    decoration: BoxDecoration(
                      gradient: i == selected ? AppTheme.redGradient : null,
                      color: i == selected
                          ? null
                          : colors.onSurfaceVariant.withAlpha(90),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
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
    final panel = AppTheme.panel(context);
    return Material(
      color: panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppTheme.outline(context)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/product/${product.id}', extra: product),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            return Stack(
              children: [
                Positioned(
                  left: -width * 0.06,
                  top: -28,
                  bottom: -28,
                  width: width * 0.7,
                  child: ProductImage(url: product.imageUrl, iconSize: 96),
                ),
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          panel.withAlpha(0),
                          panel.withAlpha(0),
                          panel.withAlpha(225),
                          panel,
                        ],
                        stops: const [0, 0.3, 0.55, 1],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 18,
                  top: 16,
                  bottom: 16,
                  width: width * 0.52,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (product.categoryName.isNotEmpty)
                        TagPill(text: product.categoryName.toUpperCase()),
                      const SizedBox(height: 10),
                      Text(
                        product.name,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              formatPeso(product.price),
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: AppTheme.red,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 30,
                            height: 30,
                            decoration: const BoxDecoration(
                              color: AppTheme.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
