import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_providers.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class RiffsAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const RiffsAppBar({super.key, this.title, this.showBack = false});

  final String? title;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      leading: showBack
          ? IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back_rounded),
              onPressed: () =>
                  context.canPop() ? context.pop() : context.go('/'),
            )
          : null,
      titleSpacing: showBack ? 0 : 20,
      title: title == null
          ? Text(
              'RIFFS',
              style: GoogleFonts.protestRevolution(
                color: AppTheme.red,
                fontSize: 34,
              ),
            )
          : Text(title!, style: AppTheme.display(fontSize: 24)),
      actions: [
        IconButton(
          tooltip: 'Toggle light and dark mode',
          onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
          icon: Icon(
            isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
        ),
        const _AccountMenu(),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _AccountMenu extends ConsumerWidget {
  const _AccountMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider).value;
    final theme = Theme.of(context);

    return PopupMenuButton<String>(
      tooltip: 'Account',
      icon: const Icon(Icons.account_circle_outlined),
      onSelected: (_) => ref.read(authFormProvider.notifier).signOut(),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile?.displayName ?? '',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              if (profile?.email != null)
                Text(profile!.email!, style: theme.textTheme.bodySmall),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: (profile?.isAdmin ?? false)
                      ? AppTheme.red
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  (profile?.isAdmin ?? false) ? 'ADMIN' : 'CUSTOMER',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: (profile?.isAdmin ?? false)
                        ? Colors.white
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'sign-out',
          child: Row(
            children: [
              Icon(Icons.logout_rounded, size: 20),
              SizedBox(width: 12),
              Text('Sign out'),
            ],
          ),
        ),
      ],
    );
  }
}
