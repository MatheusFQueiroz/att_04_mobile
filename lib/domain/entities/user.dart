/// Entidade de domínio que representa o usuário autenticado.
class User {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String image;
  final String accessToken;

  const User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.image,
    required this.accessToken,
  });
}
