import 'package:flutter/foundation.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import 'product_state.dart';

class ProductViewModel {
  final ProductRepository repository;
  final ValueNotifier<ProductState> state = ValueNotifier(const ProductState());

  ProductViewModel(this.repository);

  Future<void> loadProducts() async {
    state.value = state.value.copyWith(isLoading: true, error: null);
    try {
      final products = await repository.getProducts();
      state.value = state.value.copyWith(isLoading: false, products: products);
    } catch (e) {
      state.value = state.value.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> createProduct(
    String title,
    String description,
    double price,
    String thumbnail,
    String category,
  ) async {
    state.value = state.value.copyWith(isSaving: true, saveError: null);
    try {
      final newProduct = Product(
        id: DateTime.now().millisecondsSinceEpoch,
        title: title,
        description: description,
        price: price,
        thumbnail: thumbnail,
        category: category,
      );
      final created = await repository.createProduct(newProduct);
      final updatedProducts = [...state.value.products, created];
      state.value = state.value.copyWith(isSaving: false, products: updatedProducts);
      return true;
    } catch (e) {
      state.value = state.value.copyWith(isSaving: false, saveError: e.toString());
      return false;
    }
  }

  Future<bool> updateProduct(Product product) async {
    state.value = state.value.copyWith(isSaving: true, saveError: null);
    try {
      final updated = await repository.updateProduct(product);
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
      state.value = state.value.copyWith(isSaving: false, saveError: e.toString());
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      await repository.deleteProduct(id);
      final updatedProducts = state.value.products.where((p) => p.id != id).toList();
      state.value = state.value.copyWith(products: updatedProducts);
      return true;
    } catch (e) {
      state.value = state.value.copyWith(error: e.toString());
      return false;
    }
  }

  void selectProduct(Product? product) {
    state.value = state.value.copyWith(selectedProduct: product);
  }

  void toggleFavorite(int productId) {
    final updatedProducts = state.value.products.map((product) {
      if (product.id == productId) {
        return Product(
          id: product.id,
          title: product.title,
          description: product.description,
          price: product.price,
          thumbnail: product.thumbnail,
          category: product.category,
          stock: product.stock,
          rating: product.rating,
          favorite: !product.favorite,
        );
      }
      return product;
    }).toList();
    state.value = state.value.copyWith(products: updatedProducts);
  }

  void toggleFavoriteFilter() {
    state.value = state.value.copyWith(
      showOnlyFavorites: !state.value.showOnlyFavorites,
    );
  }
}
