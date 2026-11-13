import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../main.dart' show supabase;

abstract class AuthService {
  bool get isSignedIn;

  String? get email;

  Stream<void> get changes;

  Future<void> signIn({required String email, required String password});

  Future<bool> signUp({required String email, required String password});

  Future<void> signInWithGitHub();

  Future<void> signOut();
}

class SupabaseAuthService implements AuthService {
  String? get _redirectUrl => kIsWeb ? Uri.base.origin : null;

  @override
  bool get isSignedIn => supabase.auth.currentSession != null;

  @override
  String? get email => supabase.auth.currentUser?.email;

  @override
  Stream<void> get changes => supabase.auth.onAuthStateChange;

  @override
  Future<void> signIn({required String email, required String password}) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<bool> signUp({required String email, required String password}) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
      emailRedirectTo: _redirectUrl,
    );
    return response.session != null;
  }

  @override
  Future<void> signInWithGitHub() async {
    await supabase.auth.signInWithOAuth(
      OAuthProvider.github,
      redirectTo: _redirectUrl,
    );
  }

  @override
  Future<void> signOut() async {
    await supabase.auth.signOut();
  }
}
