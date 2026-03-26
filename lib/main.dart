import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'core/network/http_client.dart';
import 'data/datasources/product_cache_datasource.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/repositories/product_repository_impl.dart';
import 'presentation/pages/product_list_page.dart';
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

  // Carrega os produtos ao iniciar
  productViewModel.loadProducts();

  runApp(MyApp(viewModel: productViewModel));
}

class MyApp extends StatelessWidget {
  final ProductViewModel viewModel;

  const MyApp({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD de Produtos',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: ProductListPage(viewModel: viewModel),
    );
  }
}
