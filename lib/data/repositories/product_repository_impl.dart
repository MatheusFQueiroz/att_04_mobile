import '../../core/errors/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_cache_datasource.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

/// Implementação do repositório de produtos com suporte a cache.
///
/// Esta implementação segue a estratégia de "cache-aside" (ou "lazy loading"):
/// 1. Primeiro tenta buscar os dados da API remota
/// 2. Se sucesso: salva no cache e retorna os dados
/// 3. Se falha: tenta retornar os dados do cache (fallback)
/// 4. Se cache vazio: lança uma Failure
///
/// Para operações de escrita (create, update, delete), a API é sempre chamada primeiro.
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource remoteDatasource;
  final ProductCacheDatasource cacheDatasource;

  ProductRepositoryImpl(this.remoteDatasource, this.cacheDatasource);

  @override
  Future<List<Product>> getProducts() async {
    try {
      // Tenta buscar da API primeiro
      final models = await remoteDatasource.getProducts();

      // Salva no cache para uso futuro (offline)
      cacheDatasource.save(models);

      return models.map((m) => _mapToEntity(m)).toList();
    } catch (e) {
      // Se a API falhar, tenta usar o cache como fallback
      final cached = cacheDatasource.get();

      if (cached != null && cached.isNotEmpty) {
        return cached.map((m) => _mapToEntity(m)).toList();
      }

      throw Failure('Não foi possível carregar os produtos');
    }
  }

  @override
  Future<Product> createProduct(Product product) async {
    try {
      final model = ProductModel(
        id: product.id,
        title: product.title,
        description: product.description,
        price: product.price,
        image: product.image,
      );
      final created = await remoteDatasource.createProduct(model);
      return _mapToEntity(created);
    } catch (e) {
      throw Failure('Não foi possível criar o produto');
    }
  }

  @override
  Future<Product> updateProduct(Product product) async {
    try {
      final model = ProductModel(
        id: product.id,
        title: product.title,
        description: product.description,
        price: product.price,
        image: product.image,
      );
      final updated = await remoteDatasource.updateProduct(model);
      return _mapToEntity(updated);
    } catch (e) {
      throw Failure('Não foi possível atualizar o produto');
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    try {
      await remoteDatasource.deleteProduct(id);
    } catch (e) {
      throw Failure('Não foi possível deletar o produto');
    }
  }

  /// Converte um ProductModel para Product (entidade de domínio).
  Product _mapToEntity(ProductModel m) {
    return Product(
      id: m.id,
      title: m.title,
      description: m.description,
      price: m.price,
      image: m.image,
    );
  }
}
