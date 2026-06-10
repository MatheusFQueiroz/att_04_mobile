/// DTO para a resposta de autenticação da DummyJSON.
class UserModel {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String image;
  final String accessToken;

  UserModel({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.image,
    required this.accessToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      username: json['username'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      image: json['image'] as String? ?? '',
      accessToken: json['accessToken'] as String,
    );
  }
}
