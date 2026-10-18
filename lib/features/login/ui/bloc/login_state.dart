import 'package:moviles_auth/features/auth/domain/entities/authenticated_user.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState {
  final LoginStatus status;
  final AuthenticatedUser? authUser;
  final String? errorMessage;

  const LoginState({
    this.status = LoginStatus.initial,
    this.authUser,
    this.errorMessage,
  });

  LoginState copyWith({
    LoginStatus? status,
    AuthenticatedUser? authUser,
    String? errorMessage,
  }) {
    return LoginState(
      status: status ?? this.status,
      authUser: authUser ?? this.authUser,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
