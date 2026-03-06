// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures, and you can use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

import 'package:att_04_mobile_02/core/network/http_client.dart';
import 'package:att_04_mobile_02/data/datasources/product_remote_datasource.dart';
import 'package:att_04_mobile_02/data/repositories/product_repository_impl.dart';
import 'package:att_04_mobile_02/main.dart';
import 'package:att_04_mobile_02/presentation/viewmodels/product_viewmodel.dart';

void main() {
  testWidgets('App builds and shows product page', (WidgetTester tester) async {
    // Setup dependencies
    final httpClient = HttpClient(http.Client());
    final remoteDatasource = ProductRemoteDatasource(httpClient);
    final productRepository = ProductRepositoryImpl(remoteDatasource);
    final productViewModel = ProductViewModel(productRepository);

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(viewModel: productViewModel));

    // Verify that the app title is displayed
    expect(find.text('Produtos'), findsOneWidget);

    // Verify loading state or empty state is shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
