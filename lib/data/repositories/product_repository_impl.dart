import '../../core/errors/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_cache_datasource.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

/// Implementação do repositório de produtos com suporte a cache.
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDatasource remoteDatasource;
  final ProductCacheDatasource cacheDatasource;

  ProductRepositoryImpl(this.remoteDatasource, this.cacheDatasource);

  @override
  Future<List<Product>> getProducts() async {
    try {
      final models = await remoteDatasource.getProducts();
      cacheDatasource.save(models);
      return models.map(_mapToEntity).toList();
    } catch (e) {
      final cached = cacheDatasource.get();
      if (cached != null && cached.isNotEmpty) {
        return cached.map(_mapToEntity).toList();
      }
      throw Failure('Não foi possível carregar os produtos');
    }
  }

  @override
  Future<Product> getProductById(int id) async {
    try {
      final model = await remoteDatasource.getProductById(id);
      return _mapToEntity(model);
    } catch (e) {
      throw Failure('Produto não encontrado');
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
        thumbnail: product.thumbnail,
        category: product.category,
        stock: product.stock,
        rating: product.rating,
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
        thumbnail: product.thumbnail,
        category: product.category,
        stock: product.stock,
        rating: product.rating,
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

  Product _mapToEntity(ProductModel m) {
    return Product(
      id: m.id,
      title: m.title,
      description: m.description,
      price: m.price,
      thumbnail: m.thumbnail,
      category: m.category,
      stock: m.stock,
      rating: m.rating,
    );
  }
}
