import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';
import '../widgets/state_views.dart';

class SessionScreen extends ConsumerWidget {
  const SessionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);

    return Scaffold(
      body: SafeArea(
        child: profile.hasError
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ErrorView(
                    error: profile.error!,
                    onRetry: () => ref.invalidate(currentProfileProvider),
                  ),
                  TextButton(
                    onPressed: () =>
                        ref.read(authFormProvider.notifier).signOut(),
                    child: const Text('Sign out'),
                  ),
                ],
              )
            : const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading your account…'),
                  ],
                ),
              ),
      ),
    );
  }
}
