/// Lo que se guarda en la tabla profiles, unido a la cuenta por el mismo id.
class Profile {
  final String id;
  final String username;
  final String fullName;

  const Profile({
    required this.id,
    required this.username,
    required this.fullName,
  });
}
