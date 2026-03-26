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

  /// Cria um novo produto na API.
  ///
  /// [title] - Título do produto
  /// [description] - Descrição do produto
  /// [price] - Preço do produto
  /// [image] - URL da imagem do produto
  ///
  /// Retorna `true` se criado com sucesso, `false` caso contrário.
  Future<bool> createProduct(
    String title,
    String description,
    double price,
    String image,
  ) async {
    state.value = state.value.copyWith(isSaving: true, saveError: null);

    try {
      // Usa timestamp como ID temporário único
      final newProduct = Product(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        description: description,
        price: price,
        image: image,
      );

      final created = await repository.createProduct(newProduct);

      // Adiciona o novo produto à lista
      final updatedProducts = [...state.value.products, created];
      state.value = state.value.copyWith(
        isSaving: false,
        products: updatedProducts,
      );
      return true;
    } catch (e) {
      state.value = state.value.copyWith(
        isSaving: false,
        saveError: e.toString(),
      );
      return false;
    }
  }

  /// Atualiza um produto existente na API.
  ///
  /// [product] - Produto com os dados atualizados.
  ///
  /// Retorna `true` se atualizado com sucesso, `false` caso contrário.
  Future<bool> updateProduct(Product product) async {
    state.value = state.value.copyWith(isSaving: true, saveError: null);

    try {
      final updated = await repository.updateProduct(product);

      // Atualiza o produto na lista
      final updatedProducts = state.value.products.map((p) {
        return p.id == updated.id ? updated : p;
      }).toList();

      state.value = state.value.copyWith(
        isSaving: false,
        products: updatedProducts,
        selectedProduct: null,
      );
      return true;
    } catch (e) {
      state.value = state.value.copyWith(
        isSaving: false,
        saveError: e.toString(),
      );
      return false;
    }
  }

  /// Remove um produto da API.
  ///
  /// [id] - ID do produto a ser removido.
  ///
  /// Retorna `true` se removido com sucesso, `false` caso contrário.
  Future<bool> deleteProduct(int id) async {
    try {
      await repository.deleteProduct(id);

      // Remove o produto da lista local
      final updatedProducts = state.value.products
          .where((p) => p.id != id)
          .toList();
      state.value = state.value.copyWith(products: updatedProducts);
      return true;
    } catch (e) {
      state.value = state.value.copyWith(error: e.toString());
      return false;
    }
  }

  /// Seleciona um produto para edição ou visualização.
  ///
  /// [product] - Produto selecionado ou null para limpar seleção.
  void selectProduct(Product? product) {
    state.value = state.value.copyWith(selectedProduct: product);
  }

  /// Alterna o estado de favorito do produto com o [productId] fornecido.
  ///
  /// Cria uma nova lista de produtos para garantir que o [ValueNotifier]
  /// detecte a mudança de referência e notifique os listeners da UI.
  ///
  /// Não faz nada se o produto não for encontrado na lista.
  void toggleFavorite(int productId) {
    final currentProducts = state.value.products;

    final updatedProducts = currentProducts.map((product) {
      if (product.id == productId) {
        return Product(
          id: product.id,
          title: product.title,
          description: product.description,
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
