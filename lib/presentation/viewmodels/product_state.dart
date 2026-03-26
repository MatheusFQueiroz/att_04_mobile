import '../../domain/entities/product.dart';

/// Estado imutável da tela de produtos.
///
/// Contém a lista de produtos, flags de carregamento/erro,
/// controle do filtro de favoritos, e estado do formulário.
class ProductState {
  final bool isLoading;
  final bool isSaving;
  final List<Product> products;
  final String? error;
  final String? saveError;

  /// Quando [true], a lista exibida mostra apenas produtos favoritados.
  final bool showOnlyFavorites;

  /// Produto selecionado para edição ou visualização de detalhes.
  final Product? selectedProduct;

  const ProductState({
    this.isLoading = false,
    this.isSaving = false,
    this.products = const [],
    this.error,
    this.saveError,
    this.showOnlyFavorites = false,
    this.selectedProduct,
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
  /// Nota: [error] e [saveError] são sempre substituídos (não usa `??`)
  /// para permitir limpar o erro passando `null`.
  ProductState copyWith({
    bool? isLoading,
    bool? isSaving,
    List<Product>? products,
    String? error,
    String? saveError,
    bool? showOnlyFavorites,
    Product? selectedProduct,
  }) {
    return ProductState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      products: products ?? this.products,
      error: error, // substitui sempre (permite limpar)
      saveError: saveError, // substitui sempre (permite limpar)
      showOnlyFavorites: showOnlyFavorites ?? this.showOnlyFavorites,
      selectedProduct: selectedProduct ?? this.selectedProduct,
    );
  }
}
