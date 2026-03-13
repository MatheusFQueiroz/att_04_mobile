import '../../domain/entities/product.dart';

/// Estado imutável da tela de produtos.
///
/// Contém a lista de produtos, flags de carregamento/erro,
/// e controle do filtro de favoritos.
class ProductState {
  final bool isLoading;
  final List<Product> products;
  final String? error;

  /// Quando [true], a lista exibida mostra apenas produtos favoritados.
  final bool showOnlyFavorites;

  const ProductState({
    this.isLoading = false,
    this.products = const [],
    this.error,
    this.showOnlyFavorites = false,
  });

  /// Retorna o número de produtos marcados como favorito.
  int get favoriteCount => products.where((p) => p.favorite).length;

  /// Retorna a lista de produtos a ser exibida na UI.
  ///
  /// Se [showOnlyFavorites] for [true], filtra apenas os favoritos;
  /// caso contrário, retorna todos os produtos.
  List<Product> get displayedProducts {
    if (showOnlyFavorites) {
      return products.where((p) => p.favorite).toList();
    }
    return products;
  }

  /// Cria uma cópia do estado com os campos fornecidos substituídos.
  ///
  /// Nota: [error] é sempre substituído (não usa `??`) para permitir
  /// limpar o erro passando `error: null`.
  ProductState copyWith({
    bool? isLoading,
    List<Product>? products,
    String? error,
    bool? showOnlyFavorites,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      products: products ?? this.products,
      error: error, // substitui sempre (permite limpar o erro)
      showOnlyFavorites: showOnlyFavorites ?? this.showOnlyFavorites,
    );
  }
}
