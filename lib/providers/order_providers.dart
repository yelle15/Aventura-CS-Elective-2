import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_exception.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../models/product.dart';
import 'auth_providers.dart';
import 'cart_provider.dart';
import 'product_providers.dart';
import 'service_providers.dart';

final myOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final userId = await ref.watch(authUserIdProvider.future);
  if (userId == null) return const [];
  return ref.watch(orderServiceProvider).fetchMyOrders(userId);
});

final adminOrdersProvider = FutureProvider<List<Order>>((ref) async {
  final userId = await ref.watch(authUserIdProvider.future);
  if (userId == null) return const [];
  return ref.watch(orderServiceProvider).fetchAllOrders();
});

class CheckoutState {
  const CheckoutState({this.isPlacing = false, this.error});

  final bool isPlacing;
  final String? error;
}

class CheckoutNotifier extends Notifier<CheckoutState> {
  @override
  CheckoutState build() {
    ref.watch(authUserIdProvider.select((auth) => auth.value));
    ref.listen(cartProvider, (_, _) {
      if (state.error != null && !state.isPlacing) {
        state = const CheckoutState();
      }
    });
    return const CheckoutState();
  }

  Future<OrderReceipt?> placeOrder() async {
    final items = ref.read(cartProvider);
    if (items.isEmpty || state.isPlacing) return null;

    state = const CheckoutState(isPlacing: true);
    try {
      final receipt = await ref.read(orderServiceProvider).placeOrder(items);
      ref.read(cartProvider.notifier).clear();
      ref.invalidate(myOrdersProvider);
      ref.invalidate(productPageProvider);
      ref.invalidate(featuredProductsProvider);
      for (final item in items) {
        ref.invalidate(productByIdProvider(item.product.id));
      }
      state = const CheckoutState();
      return receipt;
    } catch (error) {
      await _refreshCartStock(items);
      state = CheckoutState(error: AppException.from(error).message);
      return null;
    }
  }

  Future<void> _refreshCartStock(List<CartItem> items) async {
    final service = ref.read(productServiceProvider);
    final latest = <int, Product?>{};
    for (final item in items) {
      try {
        latest[item.product.id] = await service.fetchProduct(item.product.id);
      } catch (_) {}
    }
    ref.read(cartProvider.notifier).syncStock(latest);
    ref.invalidate(productPageProvider);
    for (final id in latest.keys) {
      ref.invalidate(productByIdProvider(id));
    }
  }

  void clearError() => state = const CheckoutState();
}

final checkoutProvider = NotifierProvider<CheckoutNotifier, CheckoutState>(
  CheckoutNotifier.new,
);

class OrderActions {
  OrderActions(this._ref);

  final Ref _ref;

  Future<void> updateStatus(int orderId, String status) async {
    await _ref.read(orderServiceProvider).updateStatus(orderId, status);
    _ref.invalidate(adminOrdersProvider);
  }
}

final orderActionsProvider = Provider<OrderActions>(OrderActions.new);
