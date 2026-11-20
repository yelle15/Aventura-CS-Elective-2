import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/auth_providers.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';
import 'riffs_decor.dart';

class RiffsAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const RiffsAppBar({super.key, this.title, this.showBack = false});

  final String? title;
  final bool showBack;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AppBar(
      toolbarHeight: 72,
      leadingWidth: showBack ? 68 : null,
      leading: showBack
          ? Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Center(
                child: CircleIconButton(
                  tooltip: 'Back',
                  icon: Icons.arrow_back_rounded,
                  onPressed: () =>
                      context.canPop() ? context.pop() : context.go('/'),
                ),
              ),
            )
          : null,
      titleSpacing: showBack ? 8 : 20,
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
        Center(
          child: CircleIconButton(
            tooltip: 'Toggle light and dark mode',
            onPressed: () => ref.read(themeModeProvider.notifier).toggle(),
            icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          ),
        ),
        const SizedBox(width: 10),
        const _AccountMenu(),
        const SizedBox(width: 16),
      ],
    );
  }
}

class _AccountMenu extends ConsumerWidget {
  const _AccountMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(currentProfileProvider);
    final profile = profileState.value;
    final theme = Theme.of(context);
    final isAdmin = profile?.isAdmin ?? false;

    final Widget avatar;
    if (profileState.isLoading && profile == null) {
      avatar = Container(
        width: 42,
        height: 42,
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.panel(context),
          border: Border.all(color: AppTheme.outline(context)),
        ),
        child: const CircularProgressIndicator(strokeWidth: 2),
      );
    } else if (profileState.hasError && profile == null) {
      avatar = Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: theme.colorScheme.error.withAlpha(30),
          border: Border.all(color: theme.colorScheme.error),
        ),
        child: Icon(
          Icons.person_off_outlined,
          size: 20,
          color: theme.colorScheme.error,
        ),
      );
    } else {
      avatar = InitialsAvatar(name: profile?.displayName ?? '');
    }

    final String accountTitle;
    if (profile != null) {
      accountTitle = profile.displayName;
    } else if (profileState.hasError) {
      accountTitle = 'Could not load your profile';
    } else {
      accountTitle = 'Loading your account…';
    }

    return PopupMenuButton<String>(
      tooltip: 'Account',
      offset: const Offset(0, 54),
      onSelected: (_) => ref.read(authFormProvider.notifier).signOut(),
      itemBuilder: (context) => [
        PopupMenuItem<String>(
          enabled: false,
          child: Row(
            children: [
              InitialsAvatar(name: profile?.displayName ?? '', size: 40),
              const SizedBox(width: 12),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      accountTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (profile?.email != null)
                      Text(profile!.email!, style: theme.textTheme.bodySmall),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        gradient: isAdmin ? AppTheme.redGradient : null,
                        color: isAdmin
                            ? null
                            : theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isAdmin ? 'ADMIN' : 'CUSTOMER',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1,
                          color: isAdmin
                              ? Colors.white
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
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
      child: Center(child: avatar),
    );
  }
}
