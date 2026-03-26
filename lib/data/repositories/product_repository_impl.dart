import '../../core/errors/failure.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_cache_datasource.dart';
import '../datasources/product_remote_datasource.dart';

/// Implementação do repositório de produtos com suporte a cache.
///
/// Esta implementação segue a estratégia de "cache-aside" (ou "lazy loading"):
/// 1. Primeiro tenta buscar os dados da API remota
/// 2. Se sucesso: salva no cache e retorna os dados
/// 3. Se falha: tenta retornar os dados do cache (fallback)
/// 4. Se cache vazio: lança uma Failure
///
/// Essa abordagem garante que o usuário sempre tenha acesso aos dados
/// mais recentes quando possível, mas ainda possa visualizar dados
/// offline quando a API não estiver disponível.
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

      return models
          .map(
            (m) => Product(
              id: m.id,
              title: m.title,
              price: m.price,
              image: m.image,
            ),
          )
          .toList();
    } catch (e) {
      // Se a API falhar, tenta usar o cache como fallback
      final cached = cacheDatasource.get();

      if (cached != null && cached.isNotEmpty) {
        // Retorna dados do cache quando a API falha
        return cached
            .map(
              (m) => Product(
                id: m.id,
                title: m.title,
                price: m.price,
                image: m.image,
              ),
            )
            .toList();
      }

      // Se não há cache disponível, lança erro
      throw Failure('Não foi possível carregar os produtos');
    }
  }
}
