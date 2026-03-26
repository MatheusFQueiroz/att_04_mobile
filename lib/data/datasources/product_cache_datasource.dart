import '../models/product_model.dart';

/// Datasource responsável pelo cache em memória dos produtos.
///
/// Implementa um mecanismo simples de cache local que armazena
/// a lista de produtos em uma variável privada em memória.
///
/// Essa abordagem serve como fallback quando a API não está disponível,
/// permitindo que o usuário continue vendo os dados previamente carregados.
class ProductCacheDatasource {
  List<ProductModel>? _cache;

  /// Salva a lista de produtos no cache em memória.
  ///
  /// [products] - Lista de ProductModel a ser armazenada
  void save(List<ProductModel> products) {
    _cache = products;
  }

  /// Recupera a lista de produtos do cache.
  ///
  /// Retorna `null` se o cache estiver vazio ou nunca foi populado.
  List<ProductModel>? get() {
    return _cache;
  }

  /// Limpa o cache, removendo todos os dados armazenados.
  void clear() {
    _cache = null;
  }

  /// Verifica se o cache contém dados.
  ///
  /// Retorna `true` se houver dados no cache, `false` caso contrário.
  bool hasData() {
    return _cache != null && _cache!.isNotEmpty;
  }
}
