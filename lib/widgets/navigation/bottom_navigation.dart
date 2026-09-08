import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/cart_service.dart';
import '../../services/wishlist_service.dart';
import '../../theme/app_theme.dart';

class RiftsBottomNavigation extends StatelessWidget {
  const RiftsBottomNavigation({super.key, this.selectedIndex = 0});

  final int selectedIndex;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([CartService.instance, WishlistService.instance]),
      builder: (context, _) {
        final cartCount = CartService.instance.itemCount;
        final wishlistCount = WishlistService.instance.items.length;

        return NavigationBar(
          height: 64,
          selectedIndex: selectedIndex,
          onDestinationSelected: (index) {
            if (index == selectedIndex) return;
            switch (index) {
              case 0:
                context.go('/');
                break;
              case 1:
                context.go('/wishlist');
                break;
              case 2:
                context.go('/cart');
                break;
              default:
                break;
            }
          },
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            indicatorColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface),
          ),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: wishlistCount > 0
                  ? Badge(
                      label: Text('$wishlistCount'),
                      backgroundColor: AppTheme.red,
                      child: const Icon(Icons.bookmark_border),
                    )
                  : const Icon(Icons.bookmark_border),
              selectedIcon: wishlistCount > 0
                  ? Badge(
                      label: Text('$wishlistCount'),
                      backgroundColor: AppTheme.red,
                      child: const Icon(Icons.bookmark_rounded),
                    )
                  : const Icon(Icons.bookmark_rounded),
              label: 'Wishlist',
            ),
            NavigationDestination(
              icon: cartCount > 0
                  ? Badge(
                      label: Text('$cartCount'),
                      backgroundColor: AppTheme.red,
                      child: const Icon(Icons.shopping_bag_outlined),
                    )
                  : const Icon(Icons.shopping_bag_outlined),
              selectedIcon: cartCount > 0
                  ? Badge(
                      label: Text('$cartCount'),
                      backgroundColor: AppTheme.red,
                      child: const Icon(Icons.shopping_bag_rounded),
                    )
                  : const Icon(Icons.shopping_bag_rounded),
              label: 'Cart',
            ),
          ],
        );
      },
    );
  }
}
