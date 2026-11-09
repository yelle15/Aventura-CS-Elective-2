import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';
import '../widgets/navigation/app_bar.dart';
import 'product_detail_screen.dart';

class ProductDetailLoader extends StatefulWidget {
  const ProductDetailLoader({
    super.key,
    required this.productId,
    this.onThemeToggle,
  });

  final String productId;
  final VoidCallback? onThemeToggle;

  @override
  State<ProductDetailLoader> createState() => _ProductDetailLoaderState();
}

class _ProductDetailLoaderState extends State<ProductDetailLoader> {
  late Future<Product?> _productFuture;

  @override
  void initState() {
    super.initState();
    _productFuture =
        context.read<ProductProvider>().getProductById(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product?>(
      future: _productFuture,
      builder: (context, snapshot) {
        final product = snapshot.data;
        if (snapshot.connectionState == ConnectionState.done &&
            product != null) {
          return ProductDetailScreen(
            product: product,
            onThemeToggle: widget.onThemeToggle,
          );
        }

        final isLoading = snapshot.connectionState != ConnectionState.done;
        return Scaffold(
          appBar: RiftsAppBar(
            onThemeToggle: widget.onThemeToggle ?? () {},
            showBack: true,
          ),
          body: Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.search_off_rounded, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        snapshot.hasError
                            ? 'Could not load this product.'
                            : 'This product is no longer available.',
                      ),
                      const SizedBox(height: 16),
                      OutlinedButton(
                        onPressed: () => context.go('/'),
                        child: const Text('Back to shop'),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
