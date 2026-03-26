import 'package:http/http.dart' as http;

/// Cliente HTTP para realizar requisições REST.
///
/// Suporta operações GET, POST, PUT e DELETE com tratamento
/// de headers padrão para JSON.
class HttpClient {
  final http.Client _client;

  HttpClient(this._client);

  /// Realiza uma requisição GET.
  ///
  /// [url] - URL completa da requisição.
  Future<http.Response> get(String url) async {
    return await _client.get(Uri.parse(url));
  }

  /// Realiza uma requisição POST.
  ///
  /// [url] - URL completa da requisição.
  /// [headers] - Headers opcionais (Content-Type: application/json por padrão).
  /// [body] - Corpo da requisição (será codificado como JSON se for um Map/List).
  Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return await _client.post(
      Uri.parse(url),
      headers: headers ?? {'Content-Type': 'application/json'},
      body: body,
    );
  }

  /// Realiza uma requisição PUT.
  ///
  /// [url] - URL completa da requisição.
  /// [headers] - Headers opcionais (Content-Type: application/json por padrão).
  /// [body] - Corpo da requisição (será codificado como JSON se for um Map/List).
  Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    Object? body,
  }) async {
    return await _client.put(
      Uri.parse(url),
      headers: headers ?? {'Content-Type': 'application/json'},
      body: body,
    );
  }

  /// Realiza uma requisição DELETE.
  ///
  /// [url] - URL completa da requisição.
  Future<http.Response> delete(String url) async {
    return await _client.delete(Uri.parse(url));
  }
}
