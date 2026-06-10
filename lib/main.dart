import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'core/network/http_client.dart';
import 'core/session/session_controller.dart';
import 'data/datasources/auth_remote_datasource.dart';
import 'data/datasources/product_cache_datasource.dart';
import 'data/datasources/product_remote_datasource.dart';
import 'data/repositories/product_repository_impl.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/viewmodels/auth_viewmodel.dart';
import 'presentation/viewmodels/product_viewmodel.dart';

void main() {
  // Core
  final httpClient = HttpClient(http.Client());
  final sessionController = SessionController.instance;

  // Auth
  final authDatasource = AuthRemoteDatasource(httpClient);
  final authViewModel = AuthViewModel(authDatasource, sessionController);

  // Products
  final remoteDatasource = ProductRemoteDatasource(httpClient);
  final cacheDatasource = ProductCacheDatasource();
  final productRepository = ProductRepositoryImpl(remoteDatasource, cacheDatasource);
  final productViewModel = ProductViewModel(productRepository);

  runApp(MyApp(
    authViewModel: authViewModel,
    productViewModel: productViewModel,
  ));
}

class MyApp extends StatelessWidget {
  final AuthViewModel authViewModel;
  final ProductViewModel productViewModel;

  const MyApp({
    super.key,
    required this.authViewModel,
    required this.productViewModel,
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
      home: LoginPage(
        authViewModel: authViewModel,
        productViewModel: productViewModel,
      ),
    );
  }
}
