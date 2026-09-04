import 'package:flutter/material.dart';

import '../common/app_image_placeholder.dart';

class HeroBanner extends StatelessWidget {
  const HeroBanner({super.key});

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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FIND YOUR',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      'SOUND',
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Shop for quality electric guitars at your convenience.',
                      style: TextStyle(height: 1.15),
                      textAlign: TextAlign.left,
                      softWrap: true,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: 160,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: () {},
                        child: const Text('Shop for guitars'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: isTabletWidth ? 2 : 1,
                child: const AspectRatio(
                  aspectRatio: .9,
                  child: HeroImagePlaceholder(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
