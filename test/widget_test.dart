import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:prelim_exam/app.dart';
import 'package:prelim_exam/models/product.dart';
import 'package:prelim_exam/providers/auth_provider.dart';
import 'package:prelim_exam/providers/product_provider.dart';
import 'package:prelim_exam/services/auth_service.dart';
import 'package:prelim_exam/services/product_service.dart';
import 'package:prelim_exam/widgets/product/product_grid.dart';

class FakeAuthService implements AuthService {
  FakeAuthService({this.signedIn = true});

  final _controller = StreamController<void>.broadcast();
  bool signedIn;
  int gitHubSignIns = 0;

  @override
  bool get isSignedIn => signedIn;

  @override
  String? get email => signedIn ? 'player@riffs.test' : null;

  @override
  Stream<void> get changes => _controller.stream;

  void _set(bool signedIn) {
    this.signedIn = signedIn;
    _controller.add(null);
  }

  @override
  Future<void> signIn({required String email, required String password}) async {
    if (password != 'secret123') {
      throw AuthException('Invalid login credentials');
    }
    _set(true);
  }

  @override
  Future<bool> signUp({required String email, required String password}) async {
    return false;
  }

  @override
  Future<void> signInWithGitHub() async {
    gitHubSignIns++;
    _set(true);
  }

  @override
  Future<void> signOut() async => _set(false);
}

class FakeProductService implements ProductService {
  FakeProductService(List<Product> products) : _products = [...products];

  final List<Product> _products;

  @override
  Future<ProductPage> fetchProducts({
    required int page,
    required int pageSize,
    String? category,
    double? minPrice,
    double? maxPrice,
  }) async {
    final matches = _products
        .where((p) => category == null || p.category == category)
        .where((p) => minPrice == null || p.price >= minPrice)
        .where((p) => maxPrice == null || p.price <= maxPrice)
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
    if (_products.isEmpty) return null;
    final prices = _products.map((p) => p.price).toList()..sort();
    return PriceBounds(prices.first, prices.last);
  }

  @override
  Future<List<String>> fetchCategories() async =>
      (_products.map((p) => p.category).toSet().toList()..sort());

  @override
  Future<List<Product>> fetchFeatured({int limit = 5}) async =>
      _products.take(limit).toList();

  @override
  Future<Product?> fetchProductById(String id) async {
    for (final product in _products) {
      if (product.id == id) return product;
    }
    return null;
  }

  @override
  Future<Product> updateProduct(String id, {String? name, double? price}) async {
    final index = _products.indexWhere((p) => p.id == id);
    final old = _products[index];
    final updated = Product(
      id: old.id,
      name: name ?? old.name,
      category: old.category,
      price: price ?? old.price,
      imagePath: old.imagePath,
      description: old.description,
      rating: old.rating,
    );
    _products[index] = updated;
    return updated;
  }

  @override
  Future<void> deleteProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
  }
}

Product _product(String id, String name, String category, double price) {
  return Product(
    id: id,
    name: name,
    category: category,
    price: price,
    imagePath: 'assets/images/products/missing.png',
    description: '$name description',
    rating: 4.5,
  );
}

final _sampleProducts = [
  _product('355-epiphone', '355 Epiphone Semi-Hollow', 'Electric Guitar', 52999),
  _product('stratocaster-skywing', 'Skywing Black', 'Electric Guitar', 49999),
  _product('global-b1-bass', 'Global B1 Bass', 'Bass Guitar', 15999),
  _product('global-b2-bass', 'Global B2 Natural Bass', 'Bass Guitar', 23999),
  _product('pulse-st-0037-guitar', 'Pulse ST Red', 'Electric Guitar', 8999),
  _product('stratocaster-skywing-sunburst', 'Skywing Sunburst', 'Electric Guitar', 18999),
  _product('stratocaster-skywing-blue', 'Skywing Blue', 'Electric Guitar', 9995),
  _product('semi-hollow-blue', 'Semi-Hollow Blue', 'Electric Guitar', 9995),
  _product('bass-guitar-b2-global', 'B2 Global Bass', 'Bass Guitar', 6685),
];

Widget _buildApp(ProductProvider provider, AuthService auth) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AuthProvider(service: auth)),
      ChangeNotifierProvider.value(value: provider),
    ],
    child: const RiftsApp(),
  );
}

Future<ProductProvider> _pumpShop(
  WidgetTester tester, {
  AuthService? auth,
}) async {
  final provider = ProductProvider(
    service: FakeProductService(_sampleProducts),
  );
  await tester.pumpWidget(
    _buildApp(provider..initialize(), auth ?? FakeAuthService()),
  );
  await tester.pumpAndSettle();
  return provider;
}

Finder _inGrid(String text) => find.descendant(
      of: find.byType(ProductGrid),
      matching: find.text(text),
    );

Future<void> _tapVisible(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  group('auth', () {
    testWidgets('signed-out visitors see the login screen', (tester) async {
      await _pumpShop(tester, auth: FakeAuthService(signedIn: false));

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Continue with GitHub'), findsOneWidget);
      expect(find.text('All Products'), findsNothing);
    });

    testWidgets('email sign-in opens the shop', (tester) async {
      await _pumpShop(tester, auth: FakeAuthService(signedIn: false));

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'player@riffs.test',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
      await _tapVisible(tester, find.widgetWithText(FilledButton, 'Sign in'));

      expect(find.text('Welcome back'), findsNothing);
      expect(find.text('All Products').first, findsOneWidget);
    });

    testWidgets('a wrong password shows the error', (tester) async {
      await _pumpShop(tester, auth: FakeAuthService(signedIn: false));

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'player@riffs.test',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'wrong-pass');
      await _tapVisible(tester, find.widgetWithText(FilledButton, 'Sign in'));

      expect(find.text('Invalid login credentials'), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
    });

    testWidgets('GitHub sign-in opens the shop', (tester) async {
      final auth = FakeAuthService(signedIn: false);
      await _pumpShop(tester, auth: auth);

      await _tapVisible(tester, find.text('Continue with GitHub'));

      expect(auth.gitHubSignIns, 1);
      expect(find.text('All Products').first, findsOneWidget);
    });

    testWidgets('sign up asks the user to confirm their email', (tester) async {
      await _pumpShop(tester, auth: FakeAuthService(signedIn: false));

      await _tapVisible(tester, find.text('Create an account'));
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'new@riffs.test',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'secret123');
      await _tapVisible(tester, find.widgetWithText(FilledButton, 'Sign up'));

      expect(
        find.text('Check your email to confirm your account, then sign in.'),
        findsOneWidget,
      );
    });

    testWidgets('sign out returns to the login screen', (tester) async {
      await _pumpShop(tester);

      await tester.tap(find.byTooltip('Account'));
      await tester.pumpAndSettle();
      expect(find.text('player@riffs.test'), findsOneWidget);
      await tester.tap(find.text('Sign out'));
      await tester.pumpAndSettle();

      expect(find.text('Continue with GitHub'), findsOneWidget);
    });
  });

  group('pagination', () {
    testWidgets('first page shows the 6 cheapest products', (tester) async {
      await _pumpShop(tester);

      expect(find.text('All Products').first, findsOneWidget);
      expect(find.text('Showing 1–6 of 9 products'), findsOneWidget);
      expect(find.text('Page 1 of 2'), findsOneWidget);
      expect(_inGrid('B2 Global Bass'), findsOneWidget);
      expect(_inGrid('Skywing Sunburst'), findsOneWidget);
      expect(_inGrid('355 Epiphone Semi-Hollow'), findsNothing);
    });

    testWidgets('next page loads the remaining products', (tester) async {
      await _pumpShop(tester);

      await _tapVisible(tester, find.byTooltip('Next page'));

      expect(find.text('Page 2 of 2'), findsOneWidget);
      expect(find.text('Showing 7–9 of 9 products'), findsOneWidget);
      expect(_inGrid('355 Epiphone Semi-Hollow'), findsOneWidget);
      expect(_inGrid('B2 Global Bass'), findsNothing);
    });

    testWidgets('page number buttons jump to that page', (tester) async {
      await _pumpShop(tester);

      await _tapVisible(tester, find.widgetWithText(OutlinedButton, '2'));
      expect(find.text('Page 2 of 2'), findsOneWidget);

      await _tapVisible(tester, find.byTooltip('Previous page'));
      expect(find.text('Page 1 of 2'), findsOneWidget);
    });
  });

  group('filters', () {
    testWidgets('category chips filter the product grid', (tester) async {
      await _pumpShop(tester);

      await _tapVisible(tester, find.widgetWithText(FilterChip, 'Bass Guitar'));

      expect(_inGrid('Global B1 Bass'), findsOneWidget);
      expect(_inGrid('Pulse ST Red'), findsNothing);
      expect(find.text('Page 1 of 1'), findsOneWidget);
    });

    testWidgets('price range limits the products shown', (tester) async {
      final provider = await _pumpShop(tester);

      expect(find.byType(RangeSlider), findsOneWidget);
      provider.updatePriceRange(const RangeValues(15000, 20000));
      provider.applyPriceRange();
      await tester.pumpAndSettle();

      expect(_inGrid('Global B1 Bass'), findsOneWidget);
      expect(_inGrid('Skywing Sunburst'), findsOneWidget);
      expect(_inGrid('Pulse ST Red'), findsNothing);
      expect(find.text('Showing 1–2 of 2 products'), findsOneWidget);

      await _tapVisible(tester, find.widgetWithText(TextButton, 'Reset'));
      expect(find.text('Showing 1–6 of 9 products'), findsOneWidget);
    });

    testWidgets('price and category filters combine', (tester) async {
      final provider = await _pumpShop(tester);

      provider.selectCategory('Electric Guitar');
      provider.updatePriceRange(const RangeValues(9000, 20000));
      provider.applyPriceRange();
      await tester.pumpAndSettle();

      expect(provider.products.map((p) => p.id), [
        'semi-hollow-blue',
        'stratocaster-skywing-blue',
        'stratocaster-skywing-sunburst',
      ]);
    });
  });

  group('provider', () {
    test('price bounds are rounded out to the slider step', () async {
      final provider = ProductProvider(
        service: FakeProductService(_sampleProducts),
      );
      await provider.initialize();

      expect(provider.priceBounds!.min, 6600);
      expect(provider.priceBounds!.max, 53000);
      expect(provider.isPriceFiltered, isFalse);
    });

    test('deleting the only product on the last page steps back', () async {
      final provider = ProductProvider(
        service: FakeProductService(_sampleProducts.take(7).toList()),
      );
      await provider.initialize();
      provider.nextPage();
      await Future<void>.delayed(Duration.zero);
      expect(provider.currentPage, 1);
      expect(provider.products, hasLength(1));

      await provider.deleteProduct(provider.products.single.id);

      expect(provider.currentPage, 0);
      expect(provider.totalCount, 6);
      expect(provider.totalPages, 1);
    });

    test('updating a price re-sorts the page', () async {
      final provider = ProductProvider(
        service: FakeProductService(_sampleProducts),
      );
      await provider.initialize();

      await provider.updateProduct('355-epiphone', price: 1000);

      expect(provider.products.first.id, '355-epiphone');
      expect(provider.priceBounds!.min, 1000);
    });
  });

  testWidgets('product card toggles its bookmark icon', (tester) async {
    await _pumpShop(tester);

    final bookmark = find.byIcon(Icons.bookmark_border_rounded).first;
    await tester.ensureVisible(bookmark);
    await tester.pumpAndSettle();
    await tester.tap(bookmark);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));

    expect(find.byIcon(Icons.bookmark_rounded).first, findsOneWidget);
  });

  testWidgets('theme icon toggles the app theme', (tester) async {
    await _pumpShop(tester);

    expect(find.byIcon(Icons.light_mode_outlined), findsOneWidget);
    await tester.tap(find.byIcon(Icons.light_mode_outlined));
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.dark_mode_outlined), findsOneWidget);
  });

  testWidgets('a product card routes to its detail page and back', (
    tester,
  ) async {
    await _pumpShop(tester);

    await _tapVisible(tester, _inGrid('Global B1 Bass'));

    expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    expect(find.byTooltip('Manage product'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back_rounded));
    await tester.pumpAndSettle();

    expect(find.text('FIND YOUR'), findsOneWidget);
  });
}
