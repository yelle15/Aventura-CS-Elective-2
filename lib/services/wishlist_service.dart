import 'package:flutter/material.dart';
import '../models/product.dart';

class WishlistService extends ChangeNotifier {
  static final WishlistService instance = WishlistService._internal();
  WishlistService._internal();

  final List<Product> _items = [];

  List<Product> get items => List.unmodifiable(_items);

  bool isWishlisted(String productId) {
    return _items.any((p) => p.id == productId);
  }

  bool toggleWishlist(Product product) {
    final exists = isWishlisted(product.id);
    if (exists) {
      _items.removeWhere((p) => p.id == product.id);
    } else {
      _items.add(product);
    }
    notifyListeners();
    return !exists; // Returns true if newly added, false if removed
  }

  void removeFromWishlist(String productId) {
    _items.removeWhere((p) => p.id == productId);
    notifyListeners();
  }
}
