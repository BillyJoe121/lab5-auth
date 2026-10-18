import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:moviles_auth/features/auth/data/repository/auth_repository_impl.dart';
import 'package:moviles_auth/features/auth/data/repository/profile_repository_impl.dart';
import 'package:moviles_auth/features/auth/data/source/supabase_auth_data_source.dart';
import 'package:moviles_auth/features/auth/data/source/supabase_profile_data_source.dart';
import 'package:moviles_auth/features/auth/domain/entities/authenticated_user.dart';
import 'package:moviles_auth/features/auth/domain/entities/profile.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_in_usecase.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:moviles_auth/features/auth/domain/usecases/sign_up_usecase.dart';
import 'package:moviles_auth/features/home/ui/screens/home_screen.dart';
import 'package:moviles_auth/features/login/ui/bloc/login_bloc.dart';
import 'package:moviles_auth/features/login/ui/screens/login_screen.dart';
import 'package:moviles_auth/features/register/ui/bloc/register_bloc.dart';
import 'package:moviles_auth/features/register/ui/screens/register_screen.dart';
import 'package:moviles_auth/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Project URL (botón Connect o Settings > Data API) y publishable key
  // (Settings > API Keys) de tu proyecto.
  await Supabase.initialize(
    url: 'https://tlndatcqepwvggxuubkp.supabase.co',
    publishableKey: 'sb_publishable_KlkVXxDnq0q1cK_yYW9vWQ_zYvJT4T_',
  );

  runApp(const App());
}

/// Root widget that declares the theme and the named routes.
class App extends StatelessWidget {
  final SignInUseCase? signInUseCase;
  final SignUpUseCase? signUpUseCase;
  final SignOutUseCase? signOutUseCase;

  const App({
    super.key,
    this.signInUseCase,
    this.signUpUseCase,
    this.signOutUseCase,
  });

  @override
  Widget build(BuildContext context) {
    final SignInUseCase effectiveSignIn;
    final SignUpUseCase effectiveSignUp;
    final SignOutUseCase effectiveSignOut;

    if (signInUseCase != null &&
        signUpUseCase != null &&
        signOutUseCase != null) {
      effectiveSignIn = signInUseCase!;
      effectiveSignUp = signUpUseCase!;
      effectiveSignOut = signOutUseCase!;
    } else {
      final client = Supabase.instance.client;
      final authRepo = AuthRepositoryImpl(SupabaseAuthDataSource(client));
      final profileRepo = ProfileRepositoryImpl(
        SupabaseProfileDataSource(client),
      );

      effectiveSignIn = signInUseCase ?? SignInUseCase(authRepo, profileRepo);
      effectiveSignUp = signUpUseCase ?? SignUpUseCase(authRepo, profileRepo);
      effectiveSignOut = signOutUseCase ?? SignOutUseCase(authRepo);
    }

    return MaterialApp(
      title: 'Moviles Auth',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      initialRoute: '/login',
      routes: {
        '/login': (_) => BlocProvider(
          create: (_) => LoginBloc(effectiveSignIn),
          child: const LoginScreen(),
        ),
        '/register': (_) => BlocProvider(
          create: (_) => RegisterBloc(effectiveSignUp),
          child: const RegisterScreen(),
        ),
        '/home': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args is AuthenticatedUser) {
            return HomeScreen(
              username: args.profile.username,
              fullName: args.profile.fullName,
              email: args.user.email,
              signOutUseCase: effectiveSignOut,
            );
          }
          if (args is Profile) {
            return HomeScreen(
              username: args.username,
              fullName: args.fullName,
              signOutUseCase: effectiveSignOut,
            );
          }
          return HomeScreen(signOutUseCase: effectiveSignOut);
        },
      },
    );
  }
}
