import 'dart:async';

import 'package:flutter/material.dart';

import '../../data/products.dart';
import '../../models/product.dart';

class HeroBanner extends StatefulWidget {
  const HeroBanner({super.key, required this.onShopPressed});

  final VoidCallback onShopPressed;

  @override
  State<HeroBanner> createState() => _HeroBannerState();
}

class _HeroBannerState extends State<HeroBanner> {
  late final PageController _pageController;
  Timer? _carouselTimer;
  int _currentProduct = 0;

  List<Product> get _carouselProducts => products;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _carouselTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      _showProduct((_currentProduct + 1) % _carouselProducts.length);
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _showProduct(int index) {
    if (!_pageController.hasClients) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 450),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isTabletWidth = constraints.maxWidth >= 480;
        return Container(
          height: 252,
          padding: const EdgeInsets.fromLTRB(0, 28, 0, 0),
          child: Row(
            children: [
              Expanded(
                flex: isTabletWidth ? 3 : 1,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'FIND YOUR',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'SOUND',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Find the best guitar and bass for your sound.',
                      style: TextStyle(height: 1.15),
                      textAlign: TextAlign.center,
                      softWrap: true,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 160,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: widget.onShopPressed,
                        child: const Text('Shop for guitars'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: isTabletWidth ? 2 : 1,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AspectRatio(
                      aspectRatio: .9,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _carouselProducts.length,
                        onPageChanged: (index) {
                          setState(() => _currentProduct = index);
                        },
                        itemBuilder: (context, index) {
                          final product = _carouselProducts[index];
                          return Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              product.imagePath,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) =>
                                  const Icon(Icons.music_note_rounded, size: 72),
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (var index = 0; index < _carouselProducts.length; index++)
                            GestureDetector(
                              onTap: () => _showProduct(index),
                              child: Container(
                                width: index == _currentProduct ? 18 : 6,
                                height: 6,
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                decoration: BoxDecoration(
                                  color: index == _currentProduct
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).colorScheme.onSurfaceVariant,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
