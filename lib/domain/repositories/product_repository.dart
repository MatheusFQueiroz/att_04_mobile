import '../entities/product.dart';

/// Contrato do repositório de produtos.
///
/// Define as operações disponíveis para manipulação de produtos:
/// - [getProducts]: lista todos os produtos
/// - [createProduct]: cria um novo produto
/// - [updateProduct]: atualiza um produto existente
/// - [deleteProduct]: remove um produto pelo ID
abstract class ProductRepository {
  /// Retorna a lista de todos os produtos.
  Future<List<Product>> getProducts();

  /// Cria um novo produto e retorna o produto criado (com ID gerado pela API).
  Future<Product> createProduct(Product product);

  /// Atualiza um produto existente e retorna o produto atualizado.
  Future<Product> updateProduct(Product product);

  /// Remove um produto pelo seu [id].
  Future<void> deleteProduct(int id);
}
