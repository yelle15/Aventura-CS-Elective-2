import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_exception.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';

abstract class OrderService {
  Future<OrderReceipt> placeOrder(List<CartItem> items);

  Future<List<Order>> fetchMyOrders(String userId);

  Future<List<Order>> fetchAllOrders();

  Future<void> updateStatus(int orderId, String status);
}

class SupabaseOrderService implements OrderService {
  SupabaseOrderService(this._client);

  final SupabaseClient _client;

  @override
  Future<OrderReceipt> placeOrder(List<CartItem> items) {
    return guardSupabase(() async {
      final result = await _client.rpc(
        'place_order',
        params: {
          'items': [
            for (final item in items)
              {'product_id': item.product.id, 'quantity': item.quantity},
          ],
        },
      );
      final data = Map<String, dynamic>.from(result as Map);
      return OrderReceipt(
        orderId: (data['order_id'] as num).toInt(),
        total: parseDouble(data['total']),
      );
    });
  }

  @override
  Future<List<Order>> fetchMyOrders(String userId) {
    return guardSupabase(() async {
      final rows = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      return rows.map(Order.fromMap).toList();
    });
  }

  @override
  Future<List<Order>> fetchAllOrders() {
    return guardSupabase(() async {
      final rows = await _client
          .from('orders')
          .select('*, order_items(*), profiles(firstname, lastname, email)')
          .order('created_at', ascending: false);
      return rows.map(Order.fromMap).toList();
    });
  }

  @override
  Future<void> updateStatus(int orderId, String status) {
    return guardSupabase(() async {
      final rows = await _client
          .from('orders')
          .update({'status': status})
          .eq('id', orderId)
          .select('id');
      if (rows.isEmpty) throw const PermissionDeniedException();
    });
  }
}
