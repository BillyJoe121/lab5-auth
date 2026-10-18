import 'package:moviles_auth/features/auth/domain/entities/authenticated_user.dart';
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
    final profile = await _profiles.getProfile(user.id);
    return AuthenticatedUser(user: user, profile: profile);
  }
}
