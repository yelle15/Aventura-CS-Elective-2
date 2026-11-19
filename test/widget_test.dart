import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:prelim_exam/app.dart';
import 'package:prelim_exam/core/app_exception.dart';
import 'package:prelim_exam/models/cart_item.dart';
import 'package:prelim_exam/models/order.dart';
import 'package:prelim_exam/models/product.dart';
import 'package:prelim_exam/models/product_category.dart';
import 'package:prelim_exam/models/user_profile.dart';
import 'package:prelim_exam/providers/cart_provider.dart';
import 'package:prelim_exam/providers/router_provider.dart';
import 'package:prelim_exam/providers/service_providers.dart';
import 'package:prelim_exam/services/auth_service.dart';
import 'package:prelim_exam/services/category_service.dart';
import 'package:prelim_exam/services/order_service.dart';
import 'package:prelim_exam/services/product_service.dart';
import 'package:prelim_exam/services/profile_service.dart';
import 'package:prelim_exam/services/storage_service.dart';
import 'package:prelim_exam/widgets/product_card.dart';

const customerId = 'customer-1';
const adminId = 'admin-1';

class FakeAuthService implements AuthService {
  FakeAuthService(this.userId);

  String? userId;
  final _changes = StreamController<String?>.broadcast();

  @override
  Stream<String?> userIdChanges() async* {
    yield userId;
    yield* _changes.stream;
  }

  void _set(String? id) {
    userId = id;
    _changes.add(id);
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    if (password != 'secret123') {
      throw const AppException('Invalid login credentials');
    }
    _set(email.startsWith('admin') ? adminId : customerId);
  }

  @override
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  }) async =>
      false;

  @override
  Future<void> signInWithGoogle() async => _set(customerId);

  @override
  Future<void> signOut() async => _set(null);
}

class FakeProfileService implements ProfileService {
  @override
  Future<UserProfile?> fetchProfile(String userId) async {
    return switch (userId) {
      adminId => const UserProfile(
          id: adminId,
          email: 'admin@riffs.test',
          firstname: 'Ada',
          lastname: 'Admin',
          role: 'admin',
        ),
      customerId => const UserProfile(
          id: customerId,
          email: 'cara@riffs.test',
          firstname: 'Cara',
          lastname: 'Customer',
          role: 'customer',
        ),
      _ => null,
    };
  }
}

const categories = [
  ProductCategory(id: 1, name: 'Bass Guitar'),
  ProductCategory(id: 2, name: 'Electric Guitar'),
];

Product product(int id, String name, double price, int stock, int categoryId) {
  return Product(
    id: id,
    name: name,
    price: price,
    stock: stock,
    categoryId: categoryId,
    categoryName: categories.firstWhere((c) => c.id == categoryId).name,
  );
}

List<Product> sampleProducts() => [
      product(1, 'Starter Bass', 6685, 15, 1),
      product(2, 'Pulse Red', 8999, 0, 2),
      product(3, 'Skywing Blue', 9995, 2, 2),
      product(4, 'Semi-Hollow Blue', 9995, 4, 2),
      product(5, 'Global B1 Bass', 15999, 8, 1),
      product(6, 'Skywing Sunburst', 18999, 10, 2),
      product(7, 'Global B2 Bass', 23999, 5, 1),
      product(8, 'Skywing Black', 49999, 6, 2),
      product(9, 'Epiphone 355', 52999, 2, 2),
    ];

class FakeProductService implements ProductService {
  FakeProductService(this.products);

  final List<Product> products;

  @override
  Future<ProductPage> fetchProducts({
    required int page,
    required int pageSize,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String search = '',
  }) async {
    final matches = products
        .where((p) => categoryId == null || p.categoryId == categoryId)
        .where((p) => minPrice == null || p.price >= minPrice)
        .where((p) => maxPrice == null || p.price <= maxPrice)
        .where(
          (p) => p.name.toLowerCase().contains(search.toLowerCase()),
        )
        .toList()
      ..sort((a, b) {
        final byPrice = a.price.compareTo(b.price);
        return byPrice != 0 ? byPrice : a.id.compareTo(b.id);
      });
    return ProductPage(
      items: matches.skip(page * pageSize).take(pageSize).toList(),
      totalCount: matches.length,
    );
  }

  @override
  Future<PriceBounds?> fetchPriceBounds() async {
    if (products.isEmpty) return null;
    final prices = products.map((p) => p.price).toList()..sort();
    return PriceBounds(prices.first, prices.last);
  }

  @override
  Future<List<Product>> fetchFeatured({int limit = 5}) async => const [];

  @override
  Future<Product?> fetchProduct(int id) async {
    for (final p in products) {
      if (p.id == id) return p;
    }
    return null;
  }

  @override
  Future<Product> createProduct(ProductInput input) async {
    final created = Product(
      id: products.length + 100,
      name: input.name,
      description: input.description,
      price: input.price,
      stock: input.stock,
      categoryId: input.categoryId,
      imageUrl: input.imageUrl,
    );
    products.add(created);
    return created;
  }

  @override
  Future<Product> updateProduct(int id, ProductInput input) async {
    final index = products.indexWhere((p) => p.id == id);
    final updated = Product(
      id: id,
      name: input.name,
      description: input.description,
      price: input.price,
      stock: input.stock,
      categoryId: input.categoryId,
      imageUrl: input.imageUrl,
    );
    products[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteProduct(int id) async {
    products.removeWhere((p) => p.id == id);
  }
}

class FakeCategoryService implements CategoryService {
  @override
  Future<List<ProductCategory>> fetchCategories() async => categories;

  @override
  Future<void> createCategory(String name) async {}

  @override
  Future<void> renameCategory(int id, String name) async {}

  @override
  Future<void> deleteCategory(int id) async {}
}

class FakeStorageService implements StorageService {
  @override
  Future<String> uploadProductImage({
    required Uint8List bytes,
    required String fileName,
    String? contentType,
  }) async =>
      'https://example.com/$fileName';
}

class FakeOrderService implements OrderService {
  FakeOrderService(this.products);

  final List<Product> products;
  final List<Order> orders = [];

  @override
  Future<OrderReceipt> placeOrder(List<CartItem> items) async {
    var total = 0.0;
    final lines = <OrderItem>[];
    for (final item in items) {
      final index = products.indexWhere((p) => p.id == item.product.id);
      final current = products[index];
      if (current.stock < item.quantity) {
        throw AppException('Only ${current.stock} left of "${current.name}".');
      }
      products[index] = current.copyWith(stock: current.stock - item.quantity);
      total += current.price * item.quantity;
      lines.add(
        OrderItem(
          id: lines.length + 1,
          productId: current.id,
          productName: current.name,
          unitPrice: current.price,
          quantity: item.quantity,
        ),
      );
    }
    final order = Order(
      id: orders.length + 1,
      createdAt: DateTime(2026, 11, 17, 14, orders.length),
      status: 'done',
      total: total,
      items: lines,
    );
    orders.insert(0, order);
    return OrderReceipt(orderId: order.id, total: total);
  }

  @override
  Future<List<Order>> fetchMyOrders(String userId) async => List.of(orders);

  @override
  Future<List<Order>> fetchAllOrders() async => List.of(orders);

  @override
  Future<void> updateStatus(int orderId, String status) async {}
}

class Harness {
  Harness({String? userId})
      : auth = FakeAuthService(userId),
        products = sampleProducts() {
    orders = FakeOrderService(products);
  }

  final FakeAuthService auth;
  final List<Product> products;
  late final FakeOrderService orders;
  late ProviderContainer container;

  Future<void> pump(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authServiceProvider.overrideWith((ref) => auth),
          profileServiceProvider.overrideWith((ref) => FakeProfileService()),
          productServiceProvider
              .overrideWith((ref) => FakeProductService(products)),
          categoryServiceProvider.overrideWith((ref) => FakeCategoryService()),
          storageServiceProvider.overrideWith((ref) => FakeStorageService()),
          orderServiceProvider.overrideWith((ref) => orders),
        ],
        child: const RiffsApp(),
      ),
    );
    await tester.pumpAndSettle();
    container = ProviderScope.containerOf(
      tester.element(find.byType(RiffsApp)),
    );
  }
}

Future<void> tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Finder cardFor(String name) => find.ancestor(
      of: find.text(name),
      matching: find.byType(ProductCard),
    );

Finder inCard(String name, Finder matching) =>
    find.descendant(of: cardFor(name), matching: matching);

void main() {
  group('auth gate', () {
    testWidgets('signed-out users only see the login screen', (tester) async {
      await Harness().pump(tester);

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.byType(ProductCard), findsNothing);
    });

    testWidgets('a wrong password shows the error', (tester) async {
      await Harness().pump(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'cara@riffs.test');
      await tester.enterText(find.byType(TextFormField).at(1), 'nope');
      await tapVisible(tester, find.widgetWithText(FilledButton, 'Log in'));

      expect(find.text('Invalid login credentials'), findsOneWidget);
    });

    testWidgets('signing in as a customer opens the shop', (tester) async {
      await Harness().pump(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'cara@riffs.test');
      await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
      await tapVisible(tester, find.widgetWithText(FilledButton, 'Log in'));

      expect(find.text('All Products'), findsOneWidget);
      expect(find.text('Showing 1–6 of 9 products'), findsOneWidget);
    });

    testWidgets('Google sign-in opens the shop', (tester) async {
      await Harness().pump(tester);

      await tapVisible(tester, find.text('Continue with Google'));

      expect(find.text('All Products'), findsOneWidget);
    });

    testWidgets('sign up validates the form', (tester) async {
      await Harness().pump(tester);

      await tapVisible(tester, find.text("Don't have an account? Sign up"));
      await tapVisible(tester, find.widgetWithText(FilledButton, 'Sign up'));

      expect(find.text('Enter your first name'), findsOneWidget);
      expect(find.text('Enter a valid email address'), findsOneWidget);
    });
  });

  group('customer', () {
    testWidgets('sees add to cart and no admin controls', (tester) async {
      await Harness(userId: customerId).pump(tester);

      expect(find.widgetWithText(FilledButton, 'Add to cart'), findsWidgets);
      expect(find.text('Edit'), findsNothing);
      expect(find.text('Add product'), findsNothing);
    });

    testWidgets('cannot open admin pages', (tester) async {
      final harness = Harness(userId: customerId);
      await harness.pump(tester);

      harness.container.read(routerProvider).go('/admin/products');
      await tester.pumpAndSettle();

      expect(find.text('Manage Products'), findsNothing);
      expect(find.text('All Products'), findsOneWidget);
    });

    testWidgets('pagination shows 6 per page', (tester) async {
      await Harness(userId: customerId).pump(tester);

      expect(find.byType(ProductCard), findsNWidgets(6));
      await tapVisible(tester, find.byTooltip('Next page'));

      expect(find.text('Showing 7–9 of 9 products'), findsOneWidget);
      expect(find.byType(ProductCard), findsNWidgets(3));
    });

    testWidgets('category filter narrows the products', (tester) async {
      await Harness(userId: customerId).pump(tester);

      await tapVisible(tester, find.widgetWithText(FilterChip, 'Bass Guitar'));

      expect(find.text('Showing 1–3 of 3 products'), findsOneWidget);
      expect(find.text('Pulse Red'), findsNothing);
    });

    testWidgets('out-of-stock products cannot be added', (tester) async {
      await Harness(userId: customerId).pump(tester);

      final soldOut = inCard('Pulse Red', find.byType(FilledButton));
      expect(tester.widget<FilledButton>(soldOut).onPressed, isNull);
      expect(inCard('Pulse Red', find.text('Sold out')), findsOneWidget);
    });

    testWidgets('cart stops at the available stock', (tester) async {
      final harness = Harness(userId: customerId);
      await harness.pump(tester);

      final add = inCard('Skywing Blue', find.byType(FilledButton));
      await tapVisible(tester, add);
      await tapVisible(tester, add);

      expect(harness.container.read(cartCountProvider), 2);
      expect(inCard('Skywing Blue', find.text('Max in cart')), findsOneWidget);
    });

    testWidgets('checkout saves the order and empties the cart', (tester) async {
      final harness = Harness(userId: customerId);
      await harness.pump(tester);

      await tapVisible(tester, inCard('Starter Bass', find.byType(FilledButton)));
      await tapVisible(tester, find.text('Cart'));

      expect(find.text('Your Cart'), findsOneWidget);
      await tapVisible(tester, find.widgetWithText(FilledButton, 'Checkout'));

      expect(find.text('Thank you for your order!'), findsOneWidget);
      expect(find.text('#00001'), findsOneWidget);
      expect(find.text('₱6,685'), findsOneWidget);
      expect(harness.container.read(cartCountProvider), 0);
      expect(
        harness.products.firstWhere((p) => p.id == 1).stock,
        14,
      );

      await tapVisible(tester, find.text('View my orders'));
      expect(find.text('Order #00001'), findsOneWidget);
    });

    testWidgets('a failed checkout refreshes stock in the cart', (
      tester,
    ) async {
      final harness = Harness(userId: customerId);
      await harness.pump(tester);

      final add = inCard('Skywing Blue', find.byType(FilledButton));
      await tapVisible(tester, add);
      await tapVisible(tester, add);
      final index = harness.products.indexWhere((p) => p.id == 3);
      harness.products[index] = harness.products[index].copyWith(stock: 1);

      await tapVisible(tester, find.text('Cart'));
      await tapVisible(tester, find.widgetWithText(FilledButton, 'Checkout'));

      expect(find.text('Only 1 left of "Skywing Blue".'), findsOneWidget);
      expect(harness.container.read(cartCountProvider), 1);
      expect(find.text('Max available: 1'), findsOneWidget);
      expect(harness.orders.orders, isEmpty);

      await tapVisible(tester, find.byTooltip('Remove Skywing Blue'));
      expect(find.text('Only 1 left of "Skywing Blue".'), findsNothing);
    });

    testWidgets('signing out empties the cart', (tester) async {
      final harness = Harness(userId: customerId);
      await harness.pump(tester);

      await tapVisible(tester, inCard('Starter Bass', find.byType(FilledButton)));
      expect(harness.container.read(cartCountProvider), 1);

      await tapVisible(tester, find.byTooltip('Account'));
      await tapVisible(tester, find.text('Sign out'));

      expect(find.text('Welcome back'), findsOneWidget);
      expect(harness.container.read(cartCountProvider), 0);
    });
  });

  group('admin', () {
    testWidgets('lands on product management with edit and delete', (
      tester,
    ) async {
      await Harness(userId: adminId).pump(tester);

      expect(find.text('Manage Products'), findsOneWidget);
      expect(find.text('Add product'), findsOneWidget);
      expect(find.text('Edit'), findsWidgets);
      expect(find.byTooltip('Delete Starter Bass'), findsOneWidget);
      expect(find.text('Add to cart'), findsNothing);
    });

    testWidgets('delete asks for confirmation naming the product', (
      tester,
    ) async {
      final harness = Harness(userId: adminId);
      await harness.pump(tester);

      await tapVisible(tester, find.byTooltip('Delete Starter Bass'));
      expect(find.textContaining('"Starter Bass"'), findsOneWidget);

      await tester.tap(find.widgetWithText(FilledButton, 'Delete'));
      await tester.pumpAndSettle();

      expect(harness.products.any((p) => p.id == 1), isFalse);
    });

    testWidgets('product form validates input', (tester) async {
      await Harness(userId: adminId).pump(tester);

      await tapVisible(tester, find.text('Add product'));
      await tester.enterText(find.widgetWithText(TextFormField, 'Price *'), '-5');
      await tester.enterText(find.widgetWithText(TextFormField, 'Stock *'), '1.5');
      await tapVisible(tester, find.widgetWithText(FilledButton, 'Add product'));

      expect(find.text('A product name is required'), findsOneWidget);
      expect(find.text('Price cannot be negative'), findsOneWidget);
      expect(find.text('Stock must be a whole number'), findsOneWidget);
      expect(find.text('Choose a category'), findsOneWidget);
    });

    testWidgets('edit form is pre-filled', (tester) async {
      await Harness(userId: adminId).pump(tester);

      await tapVisible(tester, inCard('Global B1 Bass', find.text('Edit')));

      expect(find.text('Edit Product'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Global B1 Bass'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '15999'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, '8'), findsOneWidget);
    });
  });
}
