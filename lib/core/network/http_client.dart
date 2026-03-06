import 'package:http/http.dart' as http;

class HttpClient {
  final http.Client _client;

  HttpClient(this._client);

  Future<http.Response> get(String url) async {
    return await _client.get(Uri.parse(url));
  }
}
