import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/cart_provider.dart';
import '../theme/app_theme.dart';

class NavItem {
  const NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    this.badgeCount = 0,
  });

  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final int badgeCount;
}

class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.routes,
  });

  final List<NavItem> items;
  final int selectedIndex;
  final List<String> routes;

  void _select(BuildContext context, int index) {
    if (index == selectedIndex) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    context.go(routes[index]);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  height: 70,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.panel(context),
                    borderRadius: BorderRadius.circular(35),
                    border: Border.all(color: AppTheme.outline(context)),
                    boxShadow: AppTheme.softShadow(context),
                  ),
                  child: Material(
                    type: MaterialType.transparency,
                    child: Row(
                      children: [
                        for (var i = 0; i < items.length; i++)
                          Expanded(
                            flex: i == selectedIndex ? 3 : 2,
                            child: _NavButton(
                              item: items[i],
                              selected: i == selectedIndex,
                              onTap: () => _select(context, i),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final NavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? Colors.white
        : Theme.of(context).colorScheme.onSurfaceVariant;
    Widget icon = Icon(
      selected ? item.selectedIcon : item.icon,
      size: 22,
      color: foreground,
    );
    if (item.badgeCount > 0) {
      icon = Badge(
        label: Text('${item.badgeCount}'),
        backgroundColor: selected ? Colors.white : AppTheme.red,
        textColor: selected ? AppTheme.red : Colors.white,
        child: icon,
      );
    }

    return InkWell(
      onTap: onTap,
      customBorder: const StadiumBorder(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutCubic,
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          gradient: selected ? AppTheme.redGradient : null,
          borderRadius: BorderRadius.circular(27),
          boxShadow: selected ? AppTheme.redGlow(alpha: 55) : null,
        ),
        child: selected
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon,
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.5,
                      ),
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon,
                  const SizedBox(height: 3),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                      fontSize: 10.5,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

class CustomerNavigation extends ConsumerWidget {
  const CustomerNavigation({super.key, required this.selectedIndex});

  final int selectedIndex;

  static const _routes = ['/', '/cart', '/orders'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(cartCountProvider);
    return FloatingNavBar(
      selectedIndex: selectedIndex,
      routes: _routes,
      items: [
        const NavItem(
          label: 'Shop',
          icon: Icons.storefront_outlined,
          selectedIcon: Icons.storefront,
        ),
        NavItem(
          label: 'Cart',
          icon: Icons.shopping_bag_outlined,
          selectedIcon: Icons.shopping_bag,
          badgeCount: count,
        ),
        const NavItem(
          label: 'Orders',
          icon: Icons.receipt_long_outlined,
          selectedIcon: Icons.receipt_long,
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
    return FloatingNavBar(
      selectedIndex: selectedIndex,
      routes: _routes,
      items: const [
        NavItem(
          label: 'Products',
          icon: Icons.inventory_2_outlined,
          selectedIcon: Icons.inventory_2,
        ),
        NavItem(
          label: 'Categories',
          icon: Icons.category_outlined,
          selectedIcon: Icons.category,
        ),
        NavItem(
          label: 'Orders',
          icon: Icons.receipt_long_outlined,
          selectedIcon: Icons.receipt_long,
        ),
      ],
    );
  }
}
