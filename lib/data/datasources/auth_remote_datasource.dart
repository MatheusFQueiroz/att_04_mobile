import 'dart:convert';
import '../../core/network/http_client.dart';
import '../models/user_model.dart';

/// Datasource responsável por autenticar o usuário via DummyJSON.
class AuthRemoteDatasource {
  final HttpClient _client;
  static const String _loginUrl = 'https://dummyjson.com/auth/login';

  AuthRemoteDatasource(this._client);

  /// Autentica o usuário com username e password.
  ///
  /// Retorna [UserModel] em caso de sucesso.
  /// Lança [Exception] se as credenciais forem inválidas (status != 200).
  Future<UserModel> login(String username, String password) async {
    final response = await _client.post(
      _loginUrl,
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    } else {
      throw Exception('Credenciais inválidas');
    }
  }
}
