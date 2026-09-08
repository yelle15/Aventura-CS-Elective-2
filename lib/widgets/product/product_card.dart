import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/product.dart';
import '../../theme/app_theme.dart';
import '../common/app_image_placeholder.dart';
import '../common/status_badge.dart';
import '../../services/wishlist_service.dart';
import '../common/wishlist_modal.dart';
import 'product_price.dart';

class ProductCard extends StatefulWidget {
  const ProductCard({super.key, required this.product, this.onTap});

  final Product product;
  final VoidCallback? onTap;

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  @override

  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      color: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.backgroundSecondary
          : AppTheme.lightCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
            color: Theme.of(context).colorScheme.outline,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap:
            widget.onTap ?? () => context.go('/product/${widget.product.id}'),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ProductImage(
                        path: widget.product.imagePath,
                        scale: widget.product.imageScale,
                        showPlaceholder: false,
                      ),
                    ),
                    if (widget.product.isNew)
                      const Positioned(
                        top: 8,
                        left: 8,
                        child: StatusBadge(label: 'NEW'),
                      ),
                    ListenableBuilder(
                      listenable: WishlistService.instance,
                      builder: (context, _) {
                        final isBookmarked = WishlistService.instance.isWishlisted(widget.product.id);
                        return Positioned(
                          top: 4,
                          right: 4,
                          child: IconButton(
                            onPressed: () {
                              final isAdded = WishlistService.instance.toggleWishlist(widget.product);
                              showWishlistModal(context, widget.product, isAdded);
                            },
                            tooltip: 'Bookmark ${widget.product.name}',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            visualDensity: VisualDensity.compact,
                            icon: Icon(
                              isBookmarked
                                  ? Icons.bookmark_rounded
                                  : Icons.bookmark_border_rounded,
                              color: isBookmarked ? AppTheme.red : AppTheme.neutral,
                              size: 22,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Text(
                widget.product.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              ProductPrice(price: widget.product.price),
            ],
          ),
        ),
      ),
    );
  }
}
