import 'dart:convert';
import '../../core/network/http_client.dart';
import '../models/product_model.dart';

/// Datasource responsável por buscar produtos da API remota (FakeStoreAPI).
///
/// Encapsula todas as chamadas HTTP relacionadas a produtos,
/// retornando modelos tipados para o repositório.
class ProductRemoteDatasource {
  final HttpClient client;

  /// URL base da FakeStoreAPI.
  static const String baseUrl = 'https://fakestoreapi.com/products';

  ProductRemoteDatasource(this.client);

  /// Busca todos os produtos da API.
  ///
  /// Retorna uma lista de [ProductModel].
  /// Lança uma [Exception] se a requisição falhar.
  Future<List<ProductModel>> getProducts() async {
    final response = await client.get(baseUrl);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => ProductModel.fromJson(json)).toList();
    } else {
      throw Exception('Falha ao carregar produtos');
    }
  }

  /// Cria um novo produto na API.
  ///
  /// [product] - Modelo do produto a ser criado.
  /// Retorna o [ProductModel] criado com o ID gerado pela API.
  /// Lança uma [Exception] se a requisição falhar.
  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await client.post(
      baseUrl,
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return ProductModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao criar produto');
    }
  }

  /// Atualiza um produto existente na API.
  ///
  /// [product] - Modelo do produto com os dados atualizados.
  /// Retorna o [ProductModel] atualizado.
  /// Lança uma [Exception] se a requisição falhar.
  Future<ProductModel> updateProduct(ProductModel product) async {
    final response = await client.put(
      '$baseUrl/${product.id}',
      body: jsonEncode(product.toJson()),
    );

    if (response.statusCode == 200) {
      return ProductModel.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Falha ao atualizar produto');
    }
  }

  /// Remove um produto da API.
  ///
  /// [id] - ID do produto a ser removido.
  /// Lança uma [Exception] se a requisição falhar.
  Future<void> deleteProduct(int id) async {
    final response = await client.delete('$baseUrl/$id');

    if (response.statusCode != 200) {
      throw Exception('Falha ao deletar produto');
    }
  }
}
