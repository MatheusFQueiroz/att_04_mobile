// Testes de widget para a ProductListPage.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:att_04_mobile_02/core/network/http_client.dart';
import 'package:att_04_mobile_02/core/session/session_controller.dart';
import 'package:att_04_mobile_02/data/datasources/auth_remote_datasource.dart';
import 'package:att_04_mobile_02/domain/entities/product.dart';
import 'package:att_04_mobile_02/domain/entities/user.dart';
import 'package:att_04_mobile_02/domain/repositories/product_repository.dart';
import 'package:att_04_mobile_02/presentation/pages/product_list_page.dart';
import 'package:att_04_mobile_02/presentation/viewmodels/auth_viewmodel.dart';
import 'package:att_04_mobile_02/presentation/viewmodels/product_viewmodel.dart';

// ─── Stubs ──────────────────────────────────────────────────────────────────

class _FakeProductRepository implements ProductRepository {
  @override
  Future<List<Product>> getProducts() async => [
    Product(
      id: 1,
      title: 'Produto Teste',
      description: 'Descrição do produto teste',
      price: 99.90,
      thumbnail: 'https://cdn.dummyjson.com/thumbnail.jpg',
      category: 'test',
      stock: 10,
      rating: 4.5,
    ),
  ];

  @override
  Future<Product> getProductById(int id) async => Product(
    id: id,
    title: 'Produto Teste',
    description: 'Descrição',
    price: 99.90,
    thumbnail: 'https://cdn.dummyjson.com/thumbnail.jpg',
    category: 'test',
    stock: 10,
    rating: 4.5,
  );

  @override
  Future<Product> createProduct(Product p) async => p;

  @override
  Future<void> deleteProduct(int id) async {}

  @override
  Future<Product> updateProduct(Product p) async => p;
}

AuthViewModel _fakeAuthViewModel() {
  final session = SessionController.testInstance()
    ..login(User(
      id: 1, username: 'testuser', firstName: 'Test',
      lastName: 'User', image: '', accessToken: 'tok',
    ));
  return AuthViewModel(
    AuthRemoteDatasource(HttpClient(http.Client())),
    session,
  );
}

Widget _buildList(ProductViewModel vm, AuthViewModel auth) {
  return MaterialApp(home: ProductListPage(viewModel: vm, authViewModel: auth));
}

// ─── Testes ─────────────────────────────────────────────────────────────────

void main() {
  testWidgets('Após loadProducts, exibe produto na lista', (tester) async {
    final vm = ProductViewModel(_FakeProductRepository());
    final auth = _fakeAuthViewModel();
    await tester.pumpWidget(_buildList(vm, auth));
    await vm.loadProducts();
    await tester.pump();
    expect(find.text('Produto Teste'), findsOneWidget);
  });

  testWidgets('Botão de filtro de favoritos está presente na AppBar', (tester) async {
    final vm = ProductViewModel(_FakeProductRepository());
    final auth = _fakeAuthViewModel();
    await tester.pumpWidget(_buildList(vm, auth));
    await tester.pump();
    expect(find.byIcon(Icons.star_border), findsOneWidget);
  });

  testWidgets('FAB de novo produto está presente', (tester) async {
    final vm = ProductViewModel(_FakeProductRepository());
    final auth = _fakeAuthViewModel();
    await tester.pumpWidget(_buildList(vm, auth));
    await tester.pump();
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Toggle de favorito exibe estrela preenchida', (tester) async {
    final vm = ProductViewModel(_FakeProductRepository());
    final auth = _fakeAuthViewModel();
    await vm.loadProducts();
    await tester.pumpWidget(_buildList(vm, auth));
    await tester.pump();
    await tester.tap(find.byIcon(Icons.star_border).first);
    await tester.pump();
    expect(find.byIcon(Icons.star), findsWidgets);
  });

  testWidgets('Logout button está presente na AppBar', (tester) async {
    final vm = ProductViewModel(_FakeProductRepository());
    final auth = _fakeAuthViewModel();
    await tester.pumpWidget(_buildList(vm, auth));
    await tester.pump();
    expect(find.byIcon(Icons.logout), findsOneWidget);
  });
}
