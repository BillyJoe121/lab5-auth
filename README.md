# moviles_auth

Proyecto base para el **Laboratorio 5: Flujo de login**. Trae las tres pantallas ya dibujadas, en las mismas carpetas y con los mismos nombres del mapa del laboratorio, y la navegación entre ellas. No tiene `Supabase` ni `Bloc` conectados: eso es lo que construyes en el laboratorio.

## Cómo correrlo

```bash
flutter pub get
flutter run
```

`flutter_bloc` y `supabase_flutter` ya están en el `pubspec.yaml`.

## Qué trae

```
lib/
├── main.dart                 tema y rutas nombradas
├── theme/app_theme.dart      AppColors y buildTheme()
├── components/
│   ├── primary_button.dart   botón con estado de carga
│   ├── error_message.dart    mensaje de error bajo el formulario
│   └── profile_field.dart    fila de dato del perfil
└── features/
    ├── login/ui/screens/login_screen.dart
    ├── register/ui/screens/register_screen.dart
    └── home/ui/screens/home_screen.dart
```

| Ruta | Pantalla | Qué hace hoy |
| --- | --- | --- |
| `/login` | `LoginScreen` | Valida que los campos no estén vacíos y navega a `/home` |
| `/register` | `RegisterScreen` | Valida los campos, compara las dos contraseñas y navega a `/home` |
| `/home` | `HomeScreen` | Muestra datos de ejemplo y vuelve a `/login` al cerrar sesión |

## Qué te toca conectar

- **Las capas de adentro.** Crea `features/auth/domain` y `features/auth/data` como indica el mapa del laboratorio.
- **Los `Bloc`.** Crea `login/ui/bloc/` y `register/ui/bloc/` junto a la carpeta `screens/` de cada feature.
- **`main.dart`.** Inicializa `Supabase` y envuelve cada ruta en su `BlocProvider`.
- **`LoginScreen` y `RegisterScreen`.** Hoy guardan `_isLoading` y `_errorMessage` con `setState`, y `_submit()` navega directo. Reemplaza eso por tu `Bloc`: `_submit()` lanza el evento, `BlocBuilder` decide el `isLoading` del `PrimaryButton` y el `ErrorMessage`, y `BlocListener` navega cuando el estado es `success`.
- **`HomeScreen`.** Hoy recibe `username`, `fullName` y `email` con valores de ejemplo. Pásale los datos reales del usuario que inició sesión, y haz que `Cerrar sesión` llame a `signOut` antes de navegar.

## Laboratorio 5 · Parte 1: registro (hecho)

El registro ya pasa por las capas. `SignUpUseCase` es la única pieza que sabe que son dos pasos: primero crea la cuenta en Supabase Auth y después guarda la fila en `profiles` con el id que devolvió Auth. Si el segundo paso falla, cierra la sesión y lanza un `AuthFailure` que la pantalla muestra.

```
lib/features/
├── auth/
│   ├── domain/   entities (AuthUser, Profile), errors (AuthFailure),
│   │             repository (contratos), usecases (SignUpUseCase)
│   └── data/     source (SDK de Supabase), repository (implementaciones)
└── register/ui/
    ├── bloc/     register_event · register_state · register_bloc
    └── screens/  register_screen (BlocListener navega, BlocBuilder dibuja)
```

Antes de correr la app:

1. En `lib/main.dart`, reemplaza `TU_URL` y `TU_PUBLISHABLE_KEY` por los de tu proyecto.
2. La tabla `profiles` debe existir con `id`, `username` y `full_name`, y con el permiso de escritura para usuarios autenticados.
3. El insert necesita la sesión que abre `signUp`. Si en Supabase está activa la confirmación de correo, `signUp` no abre sesión y el perfil no se guarda: desactívala en Authentication > Sign In / Providers > Email.

`flutter test` corre sin red: las pruebas usan repositorios en memoria (`test/helpers/fake_repositories.dart`).

## Laboratorio 5 · Parte 2: inicio de sesión (hecho)

El inicio de sesión y el cierre de sesión quedaron organizados bajo la misma arquitectura limpia:

1. **Contratos (`auth/domain/repository/`):**
   - `AuthRepository`: `signIn(email, password)` y `signOut()`.
   - `ProfileRepository`: `getProfile(id)`.

2. **Capa de datos (`auth/data/`):**
   - `SupabaseAuthDataSource`: llamadas a `signInWithPassword` y `signOut`.
   - `SupabaseProfileDataSource`: consulta a la tabla `profiles` mediante `.select().eq('id', id).single()`.
   - `AuthRepositoryImpl` y `ProfileRepositoryImpl`: implementan los contratos delegando en sus fuentes de datos.

3. **Casos de uso (`auth/domain/usecases/`):**
   - `SignInUseCase`: encadena el inicio de sesión contra Auth (`signIn`) y con el ID devuelto consulta el perfil en la base de datos (`getProfile`).
   - `SignOutUseCase`: cierra la sesión activa en el proveedor de autenticación (`signOut`).

4. **Presentación (`login/ui/` y `home/ui/`):**
   - `LoginBloc`: maneja `LoginSubmitted` y emite `LoginState` con `LoginStatus` (`initial`, `loading`, `success`, `failure`) y `AuthenticatedUser`.
   - `LoginScreen`: validación local de campos no vacíos, botón con indicador de carga reactivo y `BlocListener` que navega a `/home` con los datos del usuario autenticado.
   - `HomeScreen`: muestra los datos reales del usuario (`username`, `fullName` y `email`) y el botón `Cerrar sesión` ejecuta `SignOutUseCase` antes de retornar a `/login`.
