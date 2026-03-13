import 'package:flutter/foundation.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_state.dart';

/// ViewModel responsável pela lógica de negócio da tela de produtos.
///
/// Usa [ValueNotifier] para notificar a UI sobre mudanças de estado,
/// seguindo o padrão Observer sem dependências externas.
class ProductViewModel {
  final ProductRepository repository;

  /// Estado reativo da tela. A UI escuta via [ValueListenableBuilder].
  final ValueNotifier<ProductState> state = ValueNotifier(const ProductState());

  ProductViewModel(this.repository);

  /// Carrega a lista de produtos da API e atualiza o estado.
  ///
  /// Define [isLoading] como true antes da requisição e false ao concluir.
  /// Em caso de erro, armazena a mensagem em [ProductState.error].
  Future<void> loadProducts() async {
    state.value = state.value.copyWith(isLoading: true, error: null);

    try {
      final products = await repository.getProducts();
      state.value = state.value.copyWith(isLoading: false, products: products);
    } catch (e) {
      state.value = state.value.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Alterna o estado de favorito do produto com o [productId] fornecido.
  ///
  /// Cria uma nova lista de produtos para garantir que o [ValueNotifier]
  /// detecte a mudança de referência e notifique os listeners da UI.
  ///
  /// Não faz nada se o produto não for encontrado na lista.
  void toggleFavorite(int productId) {
    final currentProducts = state.value.products;

    // Cria nova lista para garantir detecção de mudança pelo ValueNotifier
    final updatedProducts = currentProducts.map((product) {
      if (product.id == productId) {
        // Cria novo objeto Product com o campo favorite invertido
        return Product(
          id: product.id,
          title: product.title,
          price: product.price,
          image: product.image,
          favorite: !product.favorite,
        );
      }
      return product;
    }).toList();

    state.value = state.value.copyWith(products: updatedProducts);
  }

  /// Alterna o filtro entre "mostrar todos" e "mostrar apenas favoritos".
  ///
  /// Quando ativado e não há favoritos, a UI exibe uma mensagem de estado vazio.
  void toggleFavoriteFilter() {
    state.value = state.value.copyWith(
      showOnlyFavorites: !state.value.showOnlyFavorites,
    );
  }
}
