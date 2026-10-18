import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:moviles_auth/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:moviles_auth/features/register/ui/bloc/register_event.dart';
import 'package:moviles_auth/features/register/ui/bloc/register_state.dart';

export 'package:moviles_auth/features/register/ui/bloc/register_event.dart';
export 'package:moviles_auth/features/register/ui/bloc/register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final SignUpUseCase _signUp;

  RegisterBloc(this._signUp) : super(const RegisterState()) {
    on<RegisterSubmitted>(_onSubmitted);
  }

  Future<void> _onSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    // El mensaje anterior no se arrastra: se arma un estado nuevo en cada intento.
    emit(const RegisterState(status: RegisterStatus.loading));
    try {
      final profile = await _signUp(
        username: event.username,
        fullName: event.fullName,
        email: event.email,
        password: event.password,
      );
      emit(state.copyWith(status: RegisterStatus.success, profile: profile));
    } catch (e) {
      emit(
        state.copyWith(
          status: RegisterStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
