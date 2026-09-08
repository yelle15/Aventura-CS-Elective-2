import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../theme/app_theme.dart';

class RiftsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const RiftsAppBar({
    super.key,
    required this.onThemeToggle,
    this.showBack = false,
    this.actions,
  });

  final VoidCallback onThemeToggle;
  final bool showBack;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: showBack
          ? IconButton(
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go('/');
                }
              },
              tooltip: 'Back to home',
              icon: const Icon(Icons.arrow_back_rounded),
            )
          : null,
      centerTitle: false,
      titleSpacing: 0,
      title: Padding(
        padding: const EdgeInsets.only(left: 25),
        child: Text(
          'RIFFS',
          style: GoogleFonts.protestRevolution(
            color: AppTheme.red,
            fontSize: 36,
            fontStyle: FontStyle.normal,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      actions: [
        ...(actions ?? [
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
        ]),
        const SizedBox(width: 20),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
