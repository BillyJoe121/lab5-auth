import 'package:flutter_test/flutter_test.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:moviles_auth/features/login/ui/bloc/login_bloc.dart';

import '../../helpers/fake_repositories.dart';

void main() {
  late FakeAuthRepository auth;
  late FakeProfileRepository profiles;
  late LoginBloc bloc;

  setUp(() {
    auth = FakeAuthRepository();
    profiles = FakeProfileRepository();
    profiles.saved.add(
      const Profile(id: 'uid-123', username: 'ana.dev', fullName: 'Ana Gómez'),
    );
    bloc = LoginBloc(SignInUseCase(auth, profiles));
  });

  tearDown(() => bloc.close());

  LoginSubmitted submitted() =>
      LoginSubmitted(email: 'ana@icesi.edu.co', password: '123456');

  test('arranca en initial', () {
    expect(bloc.state.status, LoginStatus.initial);
  });

  test('loading y después success con el AuthenticatedUser', () async {
    bloc.add(submitted());

    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<LoginState>().having(
          (s) => s.status,
          'status',
          LoginStatus.loading,
        ),
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.success)
            .having((s) => s.authUser?.user.email, 'email', 'ana@icesi.edu.co')
            .having((s) => s.authUser?.profile.username, 'username', 'ana.dev'),
      ]),
    );
  });

  test('loading y después failure con el mensaje de error', () async {
    auth.signInError = const AuthFailure('Correo o contraseña incorrectos');
    bloc.add(submitted());

    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<LoginState>().having(
          (s) => s.status,
          'status',
          LoginStatus.loading,
        ),
        isA<LoginState>()
            .having((s) => s.status, 'status', LoginStatus.failure)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'Correo o contraseña incorrectos',
            ),
      ]),
    );
  });
}
