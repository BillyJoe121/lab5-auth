import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';

/// El insert en profiles. Es el único lugar que sabe que fullName es full_name.
class SupabaseProfileDataSource {
  final SupabaseClient _client;

  SupabaseProfileDataSource(this._client);

  Future<void> createProfile(Profile profile) async {
    await _client.from('profiles').insert({
      'id': profile.id,
      'username': profile.username,
      'full_name': profile.fullName,
    });
  }

  Future<Profile> getProfile(String id) async {
    try {
      final row = await _client.from('profiles').select().eq('id', id).single();
      return Profile(
        id: row['id'] as String,
        username: row['username'] as String,
        fullName: (row['full_name'] as String?) ?? '',
      );
    } catch (_) {
      throw const AuthFailure('No se pudo encontrar el perfil.');
    }
  }
}
