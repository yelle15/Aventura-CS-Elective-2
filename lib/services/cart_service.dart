import 'package:flutter/material.dart';
import '../models/product.dart';

class CartItem {
  CartItem({
    required this.product,
    this.quantity = 1,
  });

  final Product product;
  int quantity;

  double get totalPrice => product.price * quantity;
}

class CartService extends ChangeNotifier {
  static final CartService instance = CartService._internal();
  CartService._internal();

  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);

  void addToCart(Product product, {int quantity = 1}) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity += quantity;
    } else {
      _items.add(CartItem(product: product, quantity: quantity));
    }
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      removeFromCart(productId);
      return;
    }
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      notifyListeners();
    }
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  void completeCheckout(List<CartItem> checkoutItems) {
    for (final checkoutItem in checkoutItems) {
      final index = _items.indexWhere(
        (item) => item.product.id == checkoutItem.product.id,
      );
      if (index < 0) continue;

      final remainingQuantity = _items[index].quantity - checkoutItem.quantity;
      if (remainingQuantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = remainingQuantity;
      }
    }
    notifyListeners();
  }
}
