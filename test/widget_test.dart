// Testes de widget para a ProductListPage.
//
// Nota: o app chama loadProducts() automaticamente ao iniciar
// então os produtos devem aparecer após o pump inicial.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:att_04_mobile_02/domain/entities/product.dart';
import 'package:att_04_mobile_02/domain/repositories/product_repository.dart';
import 'package:att_04_mobile_02/main.dart';
import 'package:att_04_mobile_02/presentation/viewmodels/product_viewmodel.dart';

// ─── Stub de repositório para testes de widget ──────────────────────────────

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

// ─── Testes ─────────────────────────────────────────────────────────────────

void main() {
  testWidgets('App renderiza a ProductListPage com título correto', (
    WidgetTester tester,
  ) async {
    final viewModel = ProductViewModel(_FakeRepository());

    await tester.pumpWidget(MyApp(viewModel: viewModel));

    // Título da AppBar deve estar visível
    expect(find.text('Produtos'), findsOneWidget);
  });

  testWidgets('Após loadProducts, exibe produto na lista', (
    WidgetTester tester,
  ) async {
    final viewModel = ProductViewModel(_FakeRepository());

    await tester.pumpWidget(MyApp(viewModel: viewModel));
    await tester.pump();

    // Dispara o carregamento
    await viewModel.loadProducts();
    await tester.pump();

    // Produto deve aparecer na lista
    expect(find.text('Produto Teste'), findsOneWidget);
  });

  testWidgets('Após loadProducts, exibe produto na lista', (
    WidgetTester tester,
  ) async {
    final viewModel = ProductViewModel(_FakeRepository());

    await tester.pumpWidget(MyApp(viewModel: viewModel));

    // Dispara o carregamento
    await viewModel.loadProducts();
    await tester.pump();

    // Produto deve aparecer na lista
    expect(find.text('Produto Teste'), findsOneWidget);
  });

  testWidgets('Botão de filtro de favoritos está presente na AppBar', (
    WidgetTester tester,
  ) async {
    final viewModel = ProductViewModel(_FakeRepository());

    await tester.pumpWidget(MyApp(viewModel: viewModel));
    await tester.pump();

    // Ícone de filtro (star_border = filtro inativo) deve estar na AppBar
    expect(find.byIcon(Icons.star_border), findsOneWidget);
  });

  testWidgets('FAB de novo produto está presente', (WidgetTester tester) async {
    final viewModel = ProductViewModel(_FakeRepository());

    await tester.pumpWidget(MyApp(viewModel: viewModel));
    await tester.pump();

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Toggle de favorito exibe estrela preenchida', (
    WidgetTester tester,
  ) async {
    final viewModel = ProductViewModel(_FakeRepository());
    await viewModel.loadProducts();

    await tester.pumpWidget(MyApp(viewModel: viewModel));
    await tester.pump();

    // Toca na estrela do produto para favoritar
    await tester.tap(find.byIcon(Icons.star_border).first);
    await tester.pump();

    // Agora deve exibir estrela preenchida (favorito ativo)
    expect(find.byIcon(Icons.star), findsWidgets);
  });
}
