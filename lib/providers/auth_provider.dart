import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({AuthService? service})
      : _service = service ?? SupabaseAuthService() {
    _subscription = _service.changes.listen((_) => notifyListeners());
  }

  final AuthService _service;
  late final StreamSubscription<void> _subscription;

  bool _isBusy = false;
  String? _errorMessage;
  String? _notice;

  bool get isSignedIn => _service.isSignedIn;
  String? get email => _service.email;
  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;
  String? get notice => _notice;

  Future<void> signIn({required String email, required String password}) {
    return _run(() => _service.signIn(email: email, password: password));
  }

  Future<void> signUp({required String email, required String password}) {
    return _run(() async {
      final signedIn = await _service.signUp(email: email, password: password);
      if (!signedIn) {
        _notice = 'Check your email to confirm your account, then sign in.';
      }
    });
  }

  Future<void> signInWithGitHub() => _run(_service.signInWithGitHub);

  Future<void> signOut() => _run(_service.signOut);

  void clearMessages() {
    if (_errorMessage == null && _notice == null) return;
    _errorMessage = null;
    _notice = null;
    notifyListeners();
  }

  Future<void> _run(Future<void> Function() action) async {
    _isBusy = true;
    _errorMessage = null;
    _notice = null;
    notifyListeners();

    try {
      await action();
    } catch (error) {
      _errorMessage = _describe(error);
    }

    _isBusy = false;
    notifyListeners();
  }

  String _describe(Object error) {
    if (error is AuthException) return error.message;
    final text = error.toString();
    if (text.contains('SocketException') ||
        text.contains('ClientException') ||
        text.contains('Failed host lookup')) {
      return 'Could not reach Supabase. Check your internet connection.';
    }
    return text;
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
