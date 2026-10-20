import 'package:moviles_auth/features/auth/domain/entities/authenticated_user.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';

/// Iniciar sesión: dos pasos (Auth devuelve el usuario y con su id se trae el perfil).
class SignInUseCase {
  final AuthRepository _auth;
  final ProfileRepository _profiles;

  SignInUseCase(this._auth, this._profiles);

  Future<AuthenticatedUser> call({
    required String email,
    required String password,
  }) async {
    final user = await _auth.signIn(email: email, password: password);
    final Profile profile;
    try {
      profile = await _profiles.getProfile(user.id);
    } catch (_) {
      // La cuenta existe pero no tiene perfil: se cierra la sesión que abrió
      // signIn para no dejar a nadie dentro a medias.
      await _auth.signOut();
      throw const AuthFailure('No se pudo cargar tu perfil. Intenta de nuevo.');
    }
    return AuthenticatedUser(user: user, profile: profile);
  }
}
