import 'package:moviles_auth/features/auth/domain/entities/profile.dart';

/// El contrato del perfil.
abstract class ProfileRepository {
  Future<void> createProfile(Profile profile);

  Future<Profile> getProfile(String id);
}
