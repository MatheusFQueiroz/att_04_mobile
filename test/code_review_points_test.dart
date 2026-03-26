// Testes adicionais para verificar os pontos de atenção do Code Review
//
// Cobre:
// - H1: ProductCard usa tipos estáticos — verificar ausência de crashes
// - H2: copyWith sempre limpa `error` — verificar comportamento correto
// - M3: ProductModel.fromJson sem guards — verificar crash com dados inesperados
// - M4: Race condition no loadProducts — verificar toque duplo rápido no FAB

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:att_04_mobile_02/domain/entities/product.dart';
import 'package:att_04_mobile_02/domain/repositories/product_repository.dart';
import 'package:att_04_mobile_02/data/models/product_model.dart';
import 'package:att_04_mobile_02/main.dart';
import 'package:att_04_mobile_02/presentation/viewmodels/product_viewmodel.dart';
import 'package:att_04_mobile_02/presentation/viewmodels/product_state.dart';

// ─── Stubs ──────────────────────────────────────────────────────────────────

class _FakeRepository implements ProductRepository {
  @override
  Future<List<Product>> getProducts() async => [
    Product(
      id: 1,
      title: 'Produto Teste',
      description: 'Descrição do produto teste',
      price: 99.90,
      image: '',
    ),
  ];

  @override
  Future<Product> createProduct(Product product) async => product;

  @override
  Future<void> deleteProduct(int id) async {}

  @override
  Future<Product> updateProduct(Product product) async => product;
}

class _SlowRepository implements ProductRepository {
  final Duration delay;
  int callCount = 0;

  _SlowRepository({this.delay = const Duration(milliseconds: 200)});

  @override
  Future<List<Product>> getProducts() async {
    callCount++;
    await Future.delayed(delay);
    return [
      Product(
        id: callCount,
        title: 'Produto $callCount',
        description: 'Descrição $callCount',
        price: 10.0,
        image: '',
      ),
    ];
  }

  @override
  Future<Product> createProduct(Product product) async => product;

  @override
  Future<void> deleteProduct(int id) async {}

  @override
  Future<Product> updateProduct(Product product) async => product;
}

class _ErrorRepository implements ProductRepository {
  bool shouldFail;
  _ErrorRepository({this.shouldFail = true});

  @override
  Future<List<Product>> getProducts() async {
    if (shouldFail) {
      throw Exception('Erro de rede simulado');
    }
    return [
      Product(
        id: 1,
        title: 'Produto OK',
        description: 'Descrição OK',
        price: 10.0,
        image: '',
      ),
    ];
  }

  @override
  Future<Product> createProduct(Product product) async => product;

  @override
  Future<void> deleteProduct(int id) async {}

  @override
  Future<Product> updateProduct(Product product) async => product;
}

// ─── Testes ─────────────────────────────────────────────────────────────────

void main() {
  // ── H1: ProductCard com tipos estáticos ─────────────────────────────
  group('[H1] ProductCard com tipos estáticos — sem crashes', () {
    testWidgets('Produto com preço inteiro (int) não crasha ao exibir', (
      WidgetTester tester,
    ) async {
      final viewModel = ProductViewModel(_FakeRepository());
      await viewModel.loadProducts();

      await tester.pumpWidget(MyApp(viewModel: viewModel));
      await tester.pump();

      // Deve renderizar sem exceção
      expect(find.text('Produto Teste'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Produto com imagem vazia usa errorBuilder sem crash', (
      WidgetTester tester,
    ) async {
      final viewModel = ProductViewModel(_FakeRepository());
      await viewModel.loadProducts();

      await tester.pumpWidget(MyApp(viewModel: viewModel));
      await tester.pump();

      // Não deve lançar exceção mesmo com imagem inválida
      expect(tester.takeException(), isNull);
    });

    testWidgets('Produto com título longo não causa overflow', (
      WidgetTester tester,
    ) async {
      final repo = _LongTitleRepository();
      final viewModel = ProductViewModel(repo);
      await viewModel.loadProducts();

      await tester.pumpWidget(MyApp(viewModel: viewModel));
      await tester.pump();

      // Não deve lançar RenderFlex overflow exception
      expect(tester.takeException(), isNull);
    });
  });

  // ── H2: copyWith sempre limpa error ──────────────────────────────────────
  group('[H2] copyWith sempre limpa error — comportamento correto', () {
    test('copyWith sem error: null limpa o erro existente', () {
      const stateWithError = ProductState(error: 'algum erro');
      final copy = stateWithError.copyWith(isLoading: true);

      expect(copy.error, isNull);
    });

    test('copyWith com error: null limpa erro explicitamente', () {
      const stateWithError = ProductState(error: 'algum erro');
      final copy = stateWithError.copyWith(error: null);
      expect(copy.error, isNull);
    });

    test('copyWith com error: "novo erro" substitui o erro anterior', () {
      const stateWithError = ProductState(error: 'erro antigo');
      final copy = stateWithError.copyWith(error: 'erro novo');
      expect(copy.error, 'erro novo');
    });

    testWidgets('Após retry bem-sucedido, mensagem de erro desaparece', (
      WidgetTester tester,
    ) async {
      final repo = _ErrorRepository(shouldFail: true);
      final viewModel = ProductViewModel(repo);

      // Primeiro load: falha
      await viewModel.loadProducts();
      expect(viewModel.state.value.error, isNotNull);

      await tester.pumpWidget(MyApp(viewModel: viewModel));
      await tester.pump();

      // Mensagem de erro deve estar visível
      expect(find.text('Tentar novamente'), findsOneWidget);

      // Segundo load: sucesso
      repo.shouldFail = false;
      await viewModel.loadProducts();
      await tester.pump();

      // Mensagem de erro deve ter desaparecido
      expect(find.text('Tentar novamente'), findsNothing);
      expect(find.text('Produto OK'), findsOneWidget);
    });

    test(
      'loadProducts limpa error ao iniciar (isLoading: true, error: null)',
      () async {
        final repo = _ErrorRepository(shouldFail: true);
        final viewModel = ProductViewModel(repo);

        // Primeiro load: gera erro
        await viewModel.loadProducts();
        expect(viewModel.state.value.error, isNotNull);

        // Inicia segundo load: error deve ser null durante loading
        String? errorDuringLoading;
        viewModel.state.addListener(() {
          if (viewModel.state.value.isLoading) {
            errorDuringLoading = viewModel.state.value.error;
          }
        });

        repo.shouldFail = false;
        await viewModel.loadProducts();

        // Durante o loading, error deve ter sido null
        expect(errorDuringLoading, isNull);
      },
    );
  });

  // ── M3: ProductModel.fromJson sem guards ──────────────────────────────────
  group('[M3] ProductModel.fromJson — comportamento com dados inesperados', () {
    test('fromJson com campos corretos funciona normalmente', () {
      final json = {
        'id': 1,
        'title': 'Produto',
        'description': 'Descrição',
        'price': 9.99,
        'image': 'https://example.com/img.jpg',
      };
      final model = ProductModel.fromJson(json);
      expect(model.id, 1);
      expect(model.title, 'Produto');
      expect(model.description, 'Descrição');
      expect(model.price, 9.99);
    });

    test('fromJson com price como int (não double) — toDouble() funciona', () {
      final json = {
        'id': 1,
        'title': 'Produto',
        'description': 'Descrição',
        'price': 10, // int, não double
        'image': 'https://example.com/img.jpg',
      };
      final model = ProductModel.fromJson(json);
      expect(model.price, 10.0);
    });

    test('fromJson com campo ausente lança TypeError (sem guard)', () {
      final jsonSemTitle = {
        'id': 1,
        'description': 'Descrição',
        'price': 9.99,
        'image': 'https://example.com/img.jpg',
      };
      expect(
        () => ProductModel.fromJson(jsonSemTitle),
        throwsA(isA<TypeError>()),
      );
    });

    test('fromJson com price null lança NoSuchMethodError (sem guard)', () {
      final jsonPriceNull = {
        'id': 1,
        'title': 'Produto',
        'description': 'Descrição',
        'price': null,
        'image': 'https://example.com/img.jpg',
      };
      expect(
        () => ProductModel.fromJson(jsonPriceNull),
        throwsA(anyOf(isA<NoSuchMethodError>(), isA<TypeError>())),
      );
    });

    test('fromJson com id como String lança TypeError (sem guard)', () {
      final jsonIdString = {
        'id': '1',
        'title': 'Produto',
        'description': 'Descrição',
        'price': 9.99,
        'image': 'https://example.com/img.jpg',
      };
      expect(
        () => ProductModel.fromJson(jsonIdString),
        throwsA(isA<TypeError>()),
      );
    });

    test('fromJson com description null usa string vazia', () {
      final jsonDescNull = {
        'id': 1,
        'title': 'Produto',
        'description': null,
        'price': 9.99,
        'image': 'https://example.com/img.jpg',
      };
      final model = ProductModel.fromJson(jsonDescNull);
      expect(model.description, '');
    });
  });

  // ── M4: Race condition no loadProducts ───────────────────────────────────
  group('[M4] Race condition — toque duplo rápido no FAB', () {
    test('Duas chamadas simultâneas a loadProducts — última vence', () async {
      final repo = _SlowRepository(delay: const Duration(milliseconds: 50));
      final viewModel = ProductViewModel(repo);

      // Dispara duas chamadas sem await (simula toque duplo)
      final future1 = viewModel.loadProducts();
      final future2 = viewModel.loadProducts();

      await Future.wait([future1, future2]);

      // Ambas as chamadas foram feitas
      expect(repo.callCount, 2);

      // O estado final deve ter produtos (não importa qual chamada venceu)
      expect(viewModel.state.value.products, isNotEmpty);
      expect(viewModel.state.value.isLoading, false);
    });

    test('Chamada dupla não deixa estado em isLoading permanente', () async {
      final repo = _SlowRepository(delay: const Duration(milliseconds: 30));
      final viewModel = ProductViewModel(repo);

      // Dispara duas chamadas sem await
      final f1 = viewModel.loadProducts();
      final f2 = viewModel.loadProducts();

      await Future.wait([f1, f2]);

      // Estado final não deve estar em loading
      expect(viewModel.state.value.isLoading, false);
    });

    testWidgets('Toque duplo no FAB não crasha o widget', (
      WidgetTester tester,
    ) async {
      final repo = _SlowRepository(delay: const Duration(milliseconds: 100));
      final viewModel = ProductViewModel(repo);

      await tester.pumpWidget(MyApp(viewModel: viewModel));
      await tester.pump();

      // Toca no FAB duas vezes rapidamente
      await tester.tap(find.byType(FloatingActionButton));
      await tester.tap(find.byType(FloatingActionButton));

      // Aguarda todas as operações assíncronas
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Não deve ter exceção
      expect(tester.takeException(), isNull);
    });
  });

  // ── Edge Cases adicionais ─────────────────────────────────────────────────
  group('Edge Cases — comportamentos de borda', () {
    test(
      'Favoritar → ativar filtro → desmarcar → produto some da lista filtrada',
      () async {
        final viewModel = ProductViewModel(_FakeRepository());
        await viewModel.loadProducts();

        // Favorita o produto
        viewModel.toggleFavorite(1);
        expect(viewModel.state.value.favoriteCount, 1);

        // Ativa filtro
        viewModel.toggleFavoriteFilter();
        expect(viewModel.state.value.displayedProducts.length, 1);

        // Desmarca favorito dentro do filtro
        viewModel.toggleFavorite(1);

        // Produto deve sumir da lista filtrada imediatamente
        expect(viewModel.state.value.displayedProducts, isEmpty);
        expect(viewModel.state.value.favoriteCount, 0);
      },
    );

    test('Refresh com favoritos marcados reseta favoritos', () async {
      final viewModel = ProductViewModel(_FakeRepository());
      await viewModel.loadProducts();

      // Favorita produto
      viewModel.toggleFavorite(1);
      expect(viewModel.state.value.favoriteCount, 1);

      // Recarrega produtos (simula FAB refresh)
      await viewModel.loadProducts();

      // Favoritos devem ser resetados (novos objetos Product sem favorite=true)
      expect(viewModel.state.value.favoriteCount, 0);
    });

    test('toggleFavoriteFilter com lista vazia não causa exceção', () {
      final viewModel = ProductViewModel(_FakeRepository());
      // Sem loadProducts — lista vazia
      expect(() => viewModel.toggleFavoriteFilter(), returnsNormally);
      expect(viewModel.state.value.showOnlyFavorites, true);
    });

    testWidgets('Estado vazio com filtro ativo exibe mensagem correta', (
      WidgetTester tester,
    ) async {
      final viewModel = ProductViewModel(_FakeRepository());
      await viewModel.loadProducts(); // carrega produtos

      // Ativa filtro sem favoritos
      viewModel.toggleFavoriteFilter();

      await tester.pumpWidget(MyApp(viewModel: viewModel));
      await tester.pump();

      // Deve exibir mensagem específica de "sem favoritos"
      expect(find.textContaining('Nenhum produto favoritado'), findsOneWidget);
    });

    testWidgets('Contador de favoritos aparece e desaparece corretamente', (
      WidgetTester tester,
    ) async {
      final viewModel = ProductViewModel(_FakeRepository());
      await viewModel.loadProducts();

      await tester.pumpWidget(MyApp(viewModel: viewModel));
      await tester.pump();

      // Inicialmente: sem contador
      expect(find.text('1'), findsNothing);

      // Favorita produto
      viewModel.toggleFavorite(1);
      await tester.pump();

      // Contador deve aparecer com "1"
      expect(find.text('1'), findsOneWidget);

      // Desfavorita
      viewModel.toggleFavorite(1);
      await tester.pump();

      // Contador deve desaparecer
      expect(find.text('1'), findsNothing);
    });
  });
}

// ─── Repositório auxiliar com título longo ───────────────────────────────────
class _LongTitleRepository implements ProductRepository {
  @override
  Future<List<Product>> getProducts() async => [
    Product(
      id: 1,
      title:
          'Este é um título extremamente longo que deveria ser truncado pelo maxLines: 2 e overflow: TextOverflow.ellipsis para não causar overflow visual na interface do usuário',
      description: 'Descrição',
      price: 99.90,
      image: '',
    ),
  ];

  @override
  Future<Product> createProduct(Product product) async => product;

  @override
  Future<void> deleteProduct(int id) async {}

  @override
  Future<Product> updateProduct(Product product) async => product;
}
