import 'product.dart';

class CartItem {
  const CartItem({required this.product, required this.quantity});

  final Product product;
  final int quantity;

  double get subtotal => product.price * quantity;

  bool get isAtStockLimit => quantity >= product.stock;

  CartItem withQuantity(int quantity) =>
      CartItem(product: product, quantity: quantity);
}
