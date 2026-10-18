import 'package:moviles_auth/features/auth/domain/entities/auth_user.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/repository/auth_repository.dart';
import 'package:moviles_auth/features/auth/domain/repository/profile_repository.dart';

/// Auth en memoria: registra las llamadas y puede fallar a pedido.
class FakeAuthRepository implements AuthRepository {
  Exception? signUpError;
  Exception? signInError;
  final calls = <String>[];

  @override
  Future<AuthUser> signUp({
    required String email,
    required String password,
  }) async {
    calls.add('signUp');
    if (signUpError != null) throw signUpError!;
    return AuthUser(id: 'uid-123', email: email);
  }

  @override
  Future<AuthUser> signIn({
    required String email,
    required String password,
  }) async {
    calls.add('signIn');
    if (signInError != null) throw signInError!;
    return AuthUser(id: 'uid-123', email: email);
  }

  @override
  Future<void> signOut() async => calls.add('signOut');
}

/// Tabla profiles en memoria.
class FakeProfileRepository implements ProfileRepository {
  Exception? createError;
  Exception? getError;
  final saved = <Profile>[];

  @override
  Future<void> createProfile(Profile profile) async {
    if (createError != null) throw createError!;
    saved.add(profile);
  }

  @override
  Future<Profile> getProfile(String id) async {
    if (getError != null) throw getError!;
    return saved.firstWhere(
      (p) => p.id == id,
      orElse: () => Profile(id: id, username: 'ana.dev', fullName: 'Ana Gómez'),
    );
  }
}
