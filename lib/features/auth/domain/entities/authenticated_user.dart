import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';

/// Resultado del inicio de sesión: cuenta en Auth y datos del perfil.
class AuthenticatedUser {
  final AuthUser user;
  final Profile profile;

  const AuthenticatedUser({required this.user, required this.profile});
}
