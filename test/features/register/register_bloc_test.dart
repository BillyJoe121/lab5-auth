import 'package:flutter_test/flutter_test.dart';
import 'package:moviles_auth/features/auth/domain/errors/auth_failure.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:moviles_auth/features/register/ui/bloc/register_bloc.dart';

import '../../helpers/fake_repositories.dart';

void main() {
  late FakeAuthRepository auth;
  late RegisterBloc bloc;

  setUp(() {
    auth = FakeAuthRepository();
    bloc = RegisterBloc(SignUpUseCase(auth, FakeProfileRepository()));
  });

  tearDown(() => bloc.close());

  RegisterSubmitted submitted() => RegisterSubmitted(
    username: 'ana.dev',
    fullName: 'Ana Gómez',
    email: 'ana@icesi.edu.co',
    password: '123456',
  );

  test('arranca en initial', () {
    expect(bloc.state.status, RegisterStatus.initial);
  });

  test('loading y después success con el Profile', () async {
    bloc.add(submitted());

    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<RegisterState>().having(
          (s) => s.status,
          'status',
          RegisterStatus.loading,
        ),
        isA<RegisterState>()
            .having((s) => s.status, 'status', RegisterStatus.success)
            .having((s) => s.profile?.username, 'username', 'ana.dev'),
      ]),
    );
  });

  test('loading y después failure con el mensaje', () async {
    auth.signUpError = const AuthFailure('El correo ya existe');
    bloc.add(submitted());

    await expectLater(
      bloc.stream,
      emitsInOrder([
        isA<RegisterState>().having(
          (s) => s.status,
          'status',
          RegisterStatus.loading,
        ),
        isA<RegisterState>()
            .having((s) => s.status, 'status', RegisterStatus.failure)
            .having(
              (s) => s.errorMessage,
              'errorMessage',
              'El correo ya existe',
            ),
      ]),
    );
  });
}
