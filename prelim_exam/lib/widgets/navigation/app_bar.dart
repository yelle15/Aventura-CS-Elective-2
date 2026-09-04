import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

class RiftsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RiftsAppBar({
    super.key,
    required this.onThemeToggle,
    this.showBack = false,
  });

  final VoidCallback onThemeToggle;
  final bool showBack;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBack
          ? IconButton(
              onPressed: () => context.go('/'),
              tooltip: 'Back to home',
              icon: const Icon(Icons.arrow_back_rounded),
            )
          : PopupMenuButton<String>(
              icon: const Icon(Icons.menu_rounded),
              tooltip: 'Open menu',
              onSelected: (value) {
                if (value == 'theme') onThemeToggle();
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'theme', child: Text('Toggle theme')),
              ],
            ),
      centerTitle: false,
      titleSpacing: 0,
      title: Text(
        'RIFFS',
        style: GoogleFonts.protestRevolution(
          color: AppTheme.red,
          fontSize: 36,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.w400,
        ),
      ),
      actions: [
        if (!showBack)
          IconButton(onPressed: () {}, icon: const Icon(Icons.search)),
        if (!showBack)
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.bookmark_border_rounded),
          ),
        if (!showBack)
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.shopping_cart_outlined),
          ),
        if (!showBack)
          IconButton(
            onPressed: onThemeToggle,
            tooltip: 'Toggle light and dark mode',
            icon: Icon(
              Theme.of(context).brightness == Brightness.dark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
