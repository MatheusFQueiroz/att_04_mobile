import 'dart:convert';
import '../../core/network/http_client.dart';
import '../models/product_model.dart';

/// Datasource responsável por buscar produtos da API DummyJSON.
class ProductRemoteDatasource {
  final HttpClient client;
  static const String _baseUrl = 'https://dummyjson.com/products';

  ProductRemoteDatasource(this.client);

  /// Busca todos os produtos.
  /// DummyJSON retorna {"products": [...], "total": N, ...}
  Future<List<ProductModel>> getProducts() async {
    final response = await client.get(_baseUrl);
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> productsJson = data['products'] as List<dynamic>;
      return productsJson.map((j) => ProductModel.fromJson(j as Map<String, dynamic>)).toList();
    } else {
      throw Exception('Falha ao carregar produtos');
    }
  }

  /// Busca produto por ID.
  Future<ProductModel> getProductById(int id) async {
    final response = await client.get('$_baseUrl/$id');
    if (response.statusCode == 200) {
      return ProductModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Produto não encontrado');
    }
  }

  /// Cria produto via DummyJSON (/products/add).
  Future<ProductModel> createProduct(ProductModel product) async {
    final response = await client.post(
      '$_baseUrl/add',
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return ProductModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Falha ao criar produto');
    }
  }

  /// Atualiza produto existente.
  Future<ProductModel> updateProduct(ProductModel product) async {
    final response = await client.put(
      '$_baseUrl/${product.id}',
      body: jsonEncode(product.toJson()),
    );
    if (response.statusCode == 200) {
      return ProductModel.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      throw Exception('Falha ao atualizar produto');
    }
  }

  /// Remove produto.
  Future<void> deleteProduct(int id) async {
    final response = await client.delete('$_baseUrl/$id');
    if (response.statusCode != 200) {
      throw Exception('Falha ao deletar produto');
    }
  }
}
