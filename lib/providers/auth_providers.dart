import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_exception.dart';
import '../models/user_profile.dart';
import 'service_providers.dart';

final authUserIdProvider = StreamProvider<String?>(
  (ref) => ref.watch(authServiceProvider).userIdChanges(),
);

final currentProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final userId = await ref.watch(authUserIdProvider.future);
  if (userId == null) return null;
  final profile = await ref.watch(profileServiceProvider).fetchProfile(userId);
  if (profile == null) {
    throw const AppException(
      'Your account has no profile yet. Sign out and sign in again.',
    );
  }
  return profile;
});

final isAdminProvider = Provider<bool>(
  (ref) => ref.watch(currentProfileProvider).value?.isAdmin ?? false,
);

class AuthFormState {
  const AuthFormState({this.isBusy = false, this.error, this.notice});

  final bool isBusy;
  final String? error;
  final String? notice;
}

class AuthFormNotifier extends Notifier<AuthFormState> {
  @override
  AuthFormState build() => const AuthFormState();

  Future<void> signIn(String email, String password) => _run(
        () => ref
            .read(authServiceProvider)
            .signInWithEmail(email: email, password: password),
      );

  Future<void> signUp({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  }) {
    return _run(() async {
      final signedIn = await ref.read(authServiceProvider).signUpWithEmail(
            email: email,
            password: password,
            firstname: firstname,
            lastname: lastname,
          );
      if (!signedIn) {
        state = AuthFormState(
          notice: 'We sent a confirmation link to $email. '
              'Open it, then log in.',
        );
      }
    });
  }

  Future<void> signInWithGoogle() =>
      _run(() => ref.read(authServiceProvider).signInWithGoogle());

  Future<void> signOut() => _run(() => ref.read(authServiceProvider).signOut());

  void clearMessages() => state = const AuthFormState();

  Future<void> _run(Future<void> Function() action) async {
    state = const AuthFormState(isBusy: true);
    try {
      await action();
      if (state.isBusy) state = const AuthFormState();
    } catch (error) {
      state = AuthFormState(error: AppException.from(error).message);
    }
  }
}

final authFormProvider = NotifierProvider<AuthFormNotifier, AuthFormState>(
  AuthFormNotifier.new,
);
