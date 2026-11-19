import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cart_item.dart';
import '../models/product.dart';
import 'auth_providers.dart';

enum AddToCartResult { added, outOfStock, stockLimitReached }

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    ref.watch(authUserIdProvider.select((auth) => auth.value));
    return const [];
  }

  int quantityOf(int productId) {
    for (final item in state) {
      if (item.product.id == productId) return item.quantity;
    }
    return 0;
  }

  AddToCartResult add(Product product, {int quantity = 1}) {
    if (!product.inStock) return AddToCartResult.outOfStock;

    final current = quantityOf(product.id);
    if (current >= product.stock) return AddToCartResult.stockLimitReached;

    final next = (current + quantity).clamp(1, product.stock).toInt();
    if (current == 0) {
      state = [...state, CartItem(product: product, quantity: next)];
    } else {
      state = [
        for (final item in state)
          if (item.product.id == product.id)
            CartItem(product: product, quantity: next)
          else
            item,
      ];
    }
    return current + quantity > product.stock
        ? AddToCartResult.stockLimitReached
        : AddToCartResult.added;
  }

  void setQuantity(int productId, int quantity) {
    if (quantity <= 0) {
      remove(productId);
      return;
    }
    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.withQuantity(quantity.clamp(1, item.product.stock).toInt())
        else
          item,
    ];
  }

  void remove(int productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void syncStock(Map<int, Product?> latest) {
    final next = <CartItem>[];
    for (final item in state) {
      if (!latest.containsKey(item.product.id)) {
        next.add(item);
        continue;
      }
      final product = latest[item.product.id];
      if (product == null || !product.inStock) continue;
      next.add(
        CartItem(
          product: product,
          quantity: item.quantity.clamp(1, product.stock).toInt(),
        ),
      );
    }
    state = next;
  }

  void clear() => state = const [];
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(
  CartNotifier.new,
);

final cartCountProvider = Provider<int>(
  (ref) => ref.watch(cartProvider).fold(0, (sum, item) => sum + item.quantity),
);

final cartTotalProvider = Provider<double>(
  (ref) => ref.watch(cartProvider).fold(0.0, (sum, item) => sum + item.subtotal),
);
