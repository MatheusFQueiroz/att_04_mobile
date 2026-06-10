import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'core/network/http_client.dart';
import 'core/session/session_controller.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/product_cache_datasource.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/repositories/product_repository_impl.dart';
import 'presentation/pages/product_list_page.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/product_viewmodel.dart';

void main() {
  // Configuração de injeção de dependências
  final httpClient = HttpClient(http.Client());
  final remoteDatasource = ProductRemoteDatasource(httpClient);
  final cacheDatasource = ProductCacheDatasource();
  final productRepository = ProductRepositoryImpl(
    remoteDatasource,
    cacheDatasource,
  );
  final productViewModel = ProductViewModel(productRepository);
  final authViewModel = AuthViewModel(
    AuthRemoteDatasource(httpClient),
    SessionController.instance,
  );

  // Carrega os produtos ao iniciar
  productViewModel.loadProducts();

  runApp(MyApp(viewModel: productViewModel, authViewModel: authViewModel));
}

class MyApp extends StatelessWidget {
  final ProductViewModel viewModel;
  final AuthViewModel authViewModel;

  const MyApp({
    super.key,
    required this.viewModel,
    required this.authViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD de Produtos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ProductListPage(viewModel: viewModel, authViewModel: authViewModel),
    );
  }
}
