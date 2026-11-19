import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_exception.dart';
import '../models/user_profile.dart';

abstract class ProfileService {
  Future<UserProfile?> fetchProfile(String userId);
}

class SupabaseProfileService implements ProfileService {
  SupabaseProfileService(this._client);

  final SupabaseClient _client;

  @override
  Future<UserProfile?> fetchProfile(String userId) {
    return guardSupabase(() async {
      final row = await _client
          .from('profiles')
          .select('id, email, firstname, lastname, roles(role)')
          .eq('id', userId)
          .maybeSingle();
      return row == null ? null : UserProfile.fromMap(row);
    });
  }
}
