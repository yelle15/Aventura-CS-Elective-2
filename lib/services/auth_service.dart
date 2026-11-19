import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_exception.dart';

abstract class AuthService {
  Stream<String?> userIdChanges();

  Future<void> signInWithEmail({
    required String email,
    required String password,
  });

  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  });

  Future<void> signInWithGoogle();

  Future<void> signOut();
}

class SupabaseAuthService implements AuthService {
  SupabaseAuthService(this._client);

  final SupabaseClient _client;

  String? get _redirectUrl => kIsWeb ? Uri.base.origin : null;

  @override
  Stream<String?> userIdChanges() {
    return _client.auth.onAuthStateChange
        .map((event) => event.session?.user.id)
        .distinct();
  }

  @override
  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) {
    return guardSupabase(
      () => _client.auth.signInWithPassword(email: email, password: password),
    );
  }

  @override
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
  }) {
    return guardSupabase(() async {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: _redirectUrl,
        data: {'firstname': firstname, 'lastname': lastname},
      );
      return response.session != null;
    });
  }

  @override
  Future<void> signInWithGoogle() {
    return guardSupabase(
      () => _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: _redirectUrl,
      ),
    );
  }

  @override
  Future<void> signOut() => guardSupabase(() => _client.auth.signOut());
}
