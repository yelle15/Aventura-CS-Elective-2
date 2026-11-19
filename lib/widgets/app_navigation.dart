import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';

class CustomerNavigation extends ConsumerWidget {
  const CustomerNavigation({super.key, required this.selectedIndex});

  final int selectedIndex;

  static const _routes = ['/', '/cart', '/orders'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartCountProvider);
    final cartIcon = Badge(
      isLabelVisible: count > 0,
      label: Text('$count'),
      backgroundColor: AppTheme.red,
      child: const Icon(Icons.shopping_bag_outlined),
    );
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        if (index == selectedIndex) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        context.go(_routes[index]);
      },
      destinations: [
        const NavigationDestination(
          icon: Icon(Icons.storefront_outlined),
          selectedIcon: Icon(Icons.storefront),
          label: 'Shop',
        ),
        NavigationDestination(icon: cartIcon, label: 'Cart'),
        const NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Orders',
        ),
      ],
    );
  }
}

class AdminNavigation extends StatelessWidget {
  const AdminNavigation({super.key, required this.selectedIndex});

  final int selectedIndex;

  static const _routes = [
    '/admin/products',
    '/admin/categories',
    '/admin/orders',
  ];

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        if (index == selectedIndex) return;
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        context.go(_routes[index]);
      },
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.inventory_2_outlined),
          selectedIcon: Icon(Icons.inventory_2),
          label: 'Products',
        ),
        NavigationDestination(
          icon: Icon(Icons.category_outlined),
          selectedIcon: Icon(Icons.category),
          label: 'Categories',
        ),
        NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined),
          selectedIcon: Icon(Icons.receipt_long),
          label: 'Orders',
        ),
      ],
    );
  }
}
