// Testes de widget para a ProductPage.
//
// Nota: o app não chama loadProducts() automaticamente ao iniciar —
// o carregamento é acionado manualmente pelo usuário via FAB ou
// programaticamente pelo chamador. Por isso o estado inicial é vazio.

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
    Product(id: 1, title: 'Produto Teste', price: 99.90, image: ''),
  ];
}

// ─── Testes ─────────────────────────────────────────────────────────────────

void main() {
  testWidgets('App renderiza a ProductPage com título correto', (
    WidgetTester tester,
  ) async {
    final viewModel = ProductViewModel(_FakeRepository());

    await tester.pumpWidget(MyApp(viewModel: viewModel));

    // Título da AppBar deve estar visível
    expect(find.text('Produtos'), findsOneWidget);
  });

  testWidgets('Estado inicial exibe mensagem de lista vazia', (
    WidgetTester tester,
  ) async {
    final viewModel = ProductViewModel(_FakeRepository());

    await tester.pumpWidget(MyApp(viewModel: viewModel));
    await tester.pump(); // processa o frame inicial

    // Sem loadProducts chamado, a lista está vazia
    expect(find.text('Nenhum produto encontrado'), findsOneWidget);
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

  testWidgets('FAB de refresh está presente', (WidgetTester tester) async {
    final viewModel = ProductViewModel(_FakeRepository());

    await tester.pumpWidget(MyApp(viewModel: viewModel));
    await tester.pump();

    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.refresh), findsOneWidget);
  });

  testWidgets('Toggle de favorito exibe estrela preenchida', (
    WidgetTester tester,
  ) async {
    final viewModel = ProductViewModel(_FakeRepository());
    await viewModel.loadProducts();

    await tester.pumpWidget(MyApp(viewModel: viewModel));
    await tester.pump();

    // Toca na estrela do produto para favoritar
    await tester.tap(find.byIcon(Icons.star_border).last);
    await tester.pump();

    // Agora deve exibir estrela preenchida (favorito ativo)
    expect(find.byIcon(Icons.star), findsWidgets);
  });
}
