import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';

/// Registrar: primero la cuenta en Auth y después el perfil, con el id de la cuenta.
class SignUpUseCase {
  final AuthRepository _auth;
  final ProfileRepository _profiles;

  SignUpUseCase(this._auth, this._profiles);

  Future<Profile> call({
    required String username,
    required String fullName,
    required String email,
    required String password,
  }) async {
    final user = await _auth.signUp(email: email, password: password);
    final profile = Profile(
      id: user.id,
      username: username,
      fullName: fullName,
    );
    try {
      await _profiles.createProfile(profile);
    } catch (_) {
      // La cuenta ya existe pero quedó sin perfil: se cierra la sesión que
      // abrió signUp para no dejar a nadie dentro a medias.
      await _auth.signOut();
      throw const AuthFailure(
        'Tu cuenta se creó, pero no se pudo guardar el perfil.',
      );
    }
    return profile;
  }
}
