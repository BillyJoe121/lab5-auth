import 'package:flutter_test/flutter_test.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_up_usecase.dart';

import '../../helpers/fake_repositories.dart';

void main() {
  late FakeAuthRepository auth;
  late FakeProfileRepository profiles;
  late SignUpUseCase signUp;

  setUp(() {
    auth = FakeAuthRepository();
    profiles = FakeProfileRepository();
    signUp = SignUpUseCase(auth, profiles);
  });

  Future<void> register() => signUp(
    username: 'ana.dev',
    fullName: 'Ana Gómez',
    email: 'ana@icesi.edu.co',
    password: '123456',
  );

  test(
    'crea la cuenta y guarda el perfil con el id que devolvió Auth',
    () async {
      final profile = await signUp(
        username: 'ana.dev',
        fullName: 'Ana Gómez',
        email: 'ana@icesi.edu.co',
        password: '123456',
      );

      expect(profile.id, 'uid-123');
      expect(profile.username, 'ana.dev');
      expect(profile.fullName, 'Ana Gómez');
      expect(profiles.saved.single.id, 'uid-123');
    },
  );

  test('si Auth falla, no intenta guardar el perfil', () async {
    auth.signUpError = const AuthFailure('El correo ya existe');

    await expectLater(register(), throwsA(isA<AuthFailure>()));
    expect(profiles.saved, isEmpty);
  });

  test('si el perfil falla, cierra la sesión y lanza AuthFailure', () async {
    profiles.createError = Exception('permission denied for table profiles');

    await expectLater(register(), throwsA(isA<AuthFailure>()));
    expect(auth.calls, ['signUp', 'signOut']);
  });
}
