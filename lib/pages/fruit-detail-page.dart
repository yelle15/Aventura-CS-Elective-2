import 'package:flutter/material.dart';
import '../data/fruits.dart';

class FruitDetailPage extends StatelessWidget {
  final String fruitId;
  const FruitDetailPage({super.key, required this.fruitId});

  @override
  Widget build(BuildContext context) {
    final fruit = kFruits.firstWhere(
      (f) => f.id.toLowerCase() == fruitId.toLowerCase(),
      orElse: () => const Fruit(
        id: 'unknown',
        name: 'Unknown',
        imageUrl: '',
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(fruit.name)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (fruit.imageUrl.isNotEmpty)
              Image.network(
                fruit.imageUrl,
                height: 200,
                width: 200,
                fit: BoxFit.contain,
              )
            else
              const Icon(Icons.broken_image, size: 100),
            const SizedBox(height: 16),
            Text(
              fruit.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}