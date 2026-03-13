// Testes unitários para o sistema de favoritos
//
// Cobre:
// - ProductState: getters favoriteCount e displayedProducts
// - ProductViewModel: toggleFavorite e toggleFavoriteFilter

import 'package:flutter_test/flutter_test.dart';
import 'package:att_04_mobile_02/domain/entities/product.dart';
import 'package:att_04_mobile_02/presentation/viewmodels/product_state.dart';

// ─── Stub simples de repositório para testes ────────────────────────────────
import 'package:att_04_mobile_02/domain/repositories/product_repository.dart';
import 'package:att_04_mobile_02/presentation/viewmodels/product_viewmodel.dart';

class _FakeRepository implements ProductRepository {
  final List<Product> _products;
  _FakeRepository(this._products);

  @override
  Future<List<Product>> getProducts() async => _products;
}

// ─── Helpers ────────────────────────────────────────────────────────────────

List<Product> _makeProducts() => [
  Product(id: 1, title: 'Produto A', price: 10.0, image: 'img1'),
  Product(id: 2, title: 'Produto B', price: 20.0, image: 'img2'),
  Product(id: 3, title: 'Produto C', price: 30.0, image: 'img3'),
];

// ─── Testes ─────────────────────────────────────────────────────────────────

void main() {
  // ── ProductState ──────────────────────────────────────────────────────────
  group('ProductState', () {
    test('favoriteCount retorna 0 quando nenhum produto é favorito', () {
      final state = ProductState(products: _makeProducts());
      expect(state.favoriteCount, 0);
    });

    test('favoriteCount conta corretamente os produtos favoritados', () {
      final products = _makeProducts();
      products[0].favorite = true;
      products[2].favorite = true;

      final state = ProductState(products: products);
      expect(state.favoriteCount, 2);
    });

    test(
      'displayedProducts retorna todos quando showOnlyFavorites é false',
      () {
        final state = ProductState(
          products: _makeProducts(),
          showOnlyFavorites: false,
        );
        expect(state.displayedProducts.length, 3);
      },
    );

    test(
      'displayedProducts filtra apenas favoritos quando showOnlyFavorites é true',
      () {
        final products = _makeProducts();
        products[1].favorite = true; // só o produto B é favorito

        final state = ProductState(products: products, showOnlyFavorites: true);

        expect(state.displayedProducts.length, 1);
        expect(state.displayedProducts.first.id, 2);
      },
    );

    test(
      'displayedProducts retorna lista vazia quando filtro ativo e sem favoritos',
      () {
        final state = ProductState(
          products: _makeProducts(),
          showOnlyFavorites: true,
        );
        expect(state.displayedProducts, isEmpty);
      },
    );

    test('copyWith preserva showOnlyFavorites quando não fornecido', () {
      final state = const ProductState(showOnlyFavorites: true);
      final copy = state.copyWith(isLoading: true);
      expect(copy.showOnlyFavorites, true);
    });

    test('copyWith atualiza showOnlyFavorites quando fornecido', () {
      const state = ProductState(showOnlyFavorites: false);
      final copy = state.copyWith(showOnlyFavorites: true);
      expect(copy.showOnlyFavorites, true);
    });

    test('copyWith limpa error quando passado null explicitamente', () {
      final state = const ProductState(error: 'algum erro');
      final copy = state.copyWith(error: null);
      expect(copy.error, isNull);
    });
  });

  // ── ProductViewModel ──────────────────────────────────────────────────────
  group('ProductViewModel', () {
    late ProductViewModel viewModel;

    setUp(() async {
      viewModel = ProductViewModel(_FakeRepository(_makeProducts()));
      await viewModel.loadProducts(); // carrega os 3 produtos
    });

    test('loadProducts carrega produtos corretamente', () {
      expect(viewModel.state.value.products.length, 3);
      expect(viewModel.state.value.isLoading, false);
      expect(viewModel.state.value.error, isNull);
    });

    test('toggleFavorite marca produto como favorito', () {
      viewModel.toggleFavorite(1);

      final product = viewModel.state.value.products.firstWhere(
        (p) => p.id == 1,
      );
      expect(product.favorite, true);
    });

    test('toggleFavorite desmarca produto já favoritado', () {
      viewModel.toggleFavorite(2); // marca
      viewModel.toggleFavorite(2); // desmarca

      final product = viewModel.state.value.products.firstWhere(
        (p) => p.id == 2,
      );
      expect(product.favorite, false);
    });

    test('toggleFavorite não altera outros produtos', () {
      viewModel.toggleFavorite(1);

      final others = viewModel.state.value.products.where((p) => p.id != 1);
      expect(others.every((p) => !p.favorite), true);
    });

    test('toggleFavorite notifica listeners (nova referência de lista)', () {
      final listaBefore = viewModel.state.value.products;
      viewModel.toggleFavorite(1);
      final listaAfter = viewModel.state.value.products;

      // Nova lista criada — referências diferentes
      expect(identical(listaBefore, listaAfter), false);
    });

    test('toggleFavoriteFilter ativa filtro de favoritos', () {
      expect(viewModel.state.value.showOnlyFavorites, false);
      viewModel.toggleFavoriteFilter();
      expect(viewModel.state.value.showOnlyFavorites, true);
    });

    test('toggleFavoriteFilter desativa filtro ao chamar novamente', () {
      viewModel.toggleFavoriteFilter(); // ativa
      viewModel.toggleFavoriteFilter(); // desativa
      expect(viewModel.state.value.showOnlyFavorites, false);
    });

    test('favoriteCount é 0 inicialmente', () {
      expect(viewModel.state.value.favoriteCount, 0);
    });

    test('favoriteCount incrementa ao favoritar', () {
      viewModel.toggleFavorite(1);
      viewModel.toggleFavorite(3);
      expect(viewModel.state.value.favoriteCount, 2);
    });

    test('toggleFavorite com id inexistente não lança exceção', () {
      expect(() => viewModel.toggleFavorite(999), returnsNormally);
    });
  });

  // ── Product entity ────────────────────────────────────────────────────────
  group('Product entity', () {
    test('favorite é false por padrão', () {
      final p = Product(id: 1, title: 'T', price: 1.0, image: 'img');
      expect(p.favorite, false);
    });

    test('favorite pode ser definido como true na construção', () {
      final p = Product(
        id: 1,
        title: 'T',
        price: 1.0,
        image: 'img',
        favorite: true,
      );
      expect(p.favorite, true);
    });

    test('favorite pode ser alterado diretamente (mutável)', () {
      final p = Product(id: 1, title: 'T', price: 1.0, image: 'img');
      p.favorite = true;
      expect(p.favorite, true);
    });
  });
}
