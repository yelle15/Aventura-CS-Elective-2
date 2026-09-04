import 'package:flutter/material.dart';

class RiftsBottomNavigation extends StatelessWidget {
  const RiftsBottomNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      height: 64,
      selectedIndex: 0,
      onDestinationSelected: (_) {},
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF080809)
          : Theme.of(context).colorScheme.surface,
      indicatorColor: Colors.transparent,
      labelTextStyle: WidgetStatePropertyAll(
        TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface),
      ),
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: 'Home',
        ),
        NavigationDestination(
          icon: Icon(Icons.grid_view_outlined),
          label: 'Category',
        ),
        NavigationDestination(
          icon: Icon(Icons.bookmark_border),
          label: 'Wishlist',
        ),
        NavigationDestination(
          icon: Icon(Icons.shopping_bag_outlined),
          label: 'Cart',
        ),
        NavigationDestination(
          icon: Icon(Icons.person_outline),
          label: 'Account',
        ),
      ],
    );
  }
}
