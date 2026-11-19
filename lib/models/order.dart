import 'product.dart';

class OrderItem {
  const OrderItem({
    required this.id,
    required this.productName,
    required this.unitPrice,
    required this.quantity,
    this.productId,
  });

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: (map['id'] as num).toInt(),
      productId: (map['product_id'] as num?)?.toInt(),
      productName: map['product_name'] as String,
      unitPrice: parseDouble(map['unit_price']),
      quantity: (map['quantity'] as num).toInt(),
    );
  }

  final int id;
  final int? productId;
  final String productName;
  final double unitPrice;
  final int quantity;

  double get subtotal => unitPrice * quantity;
}

class Order {
  const Order({
    required this.id,
    required this.createdAt,
    required this.status,
    required this.total,
    required this.items,
    this.customerName,
    this.customerEmail,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    final items = (map['order_items'] as List<dynamic>? ?? const [])
        .cast<Map<String, dynamic>>()
        .map(OrderItem.fromMap)
        .toList()
      ..sort((a, b) => a.id.compareTo(b.id));
    final profile = map['profiles'];
    String? customerName;
    String? customerEmail;
    if (profile is Map<String, dynamic>) {
      customerName = [profile['firstname'], profile['lastname']]
          .whereType<String>()
          .where((part) => part.trim().isNotEmpty)
          .join(' ');
      customerEmail = profile['email'] as String?;
    }
    return Order(
      id: (map['id'] as num).toInt(),
      createdAt: DateTime.parse(map['created_at'] as String),
      status: map['status'] as String,
      total: parseDouble(map['total']),
      items: items,
      customerName:
          customerName == null || customerName.isEmpty ? null : customerName,
      customerEmail: customerEmail,
    );
  }

  final int id;
  final DateTime createdAt;
  final String status;
  final double total;
  final List<OrderItem> items;
  final String? customerName;
  final String? customerEmail;

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);
}

class OrderReceipt {
  const OrderReceipt({required this.orderId, required this.total});

  final int orderId;
  final double total;
}

const orderStatuses = ['pending', 'done', 'shipped', 'cancelled'];
