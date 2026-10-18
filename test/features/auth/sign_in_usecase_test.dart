import 'package:flutter_test/flutter_test.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_out_usecase.dart';

import '../../helpers/fake_repositories.dart';

void main() {
  late FakeAuthRepository auth;
  late FakeProfileRepository profiles;
  late SignInUseCase signIn;
  late SignOutUseCase signOut;

  setUp(() {
    auth = FakeAuthRepository();
    profiles = FakeProfileRepository();
    signIn = SignInUseCase(auth, profiles);
    signOut = SignOutUseCase(auth);
  });

  test('signIn devuelve el AuthUser y carga su Profile', () async {
    profiles.saved.add(
      const Profile(id: 'uid-123', username: 'ana.dev', fullName: 'Ana Gómez'),
    );

    final result = await signIn(email: 'ana@icesi.edu.co', password: '123456');

    expect(result.user.id, 'uid-123');
    expect(result.user.email, 'ana@icesi.edu.co');
    expect(result.profile.username, 'ana.dev');
    expect(result.profile.fullName, 'Ana Gómez');
    expect(auth.calls, ['signIn']);
  });

  test('si Auth falla en signIn, no consulta el perfil', () async {
    auth.signInError = const AuthFailure('Credenciales inválidas');

    await expectLater(
      signIn(email: 'ana@icesi.edu.co', password: 'bad'),
      throwsA(isA<AuthFailure>()),
    );
  });

  test('signOut delega en el repositorio', () async {
    await signOut();
    expect(auth.calls, ['signOut']);
  });
}
