import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../viewmodels/product_viewmodel.dart';
import '../widgets/product_card.dart';
import 'product_detail_page.dart';
import 'product_form_page.dart';

/// Página principal que exibe a lista de produtos com suporte a CRUD e favoritos.
///
/// Funcionalidades:
/// - Exibe contador de favoritos na AppBar
/// - Botão de filtro para alternar entre todos/favoritos
/// - Card de produto com ações: detalhes, favoritar, editar, excluir
/// - FAB para adicionar novo produto
/// - Mensagem de estado vazio quando filtro ativo e sem favoritos
class ProductListPage extends StatelessWidget {
  final ProductViewModel viewModel;

  const ProductListPage({super.key, required this.viewModel});

  /// Navega para a página de detalhes do produto.
  void _navigateToDetail(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailPage(product: product),
      ),
    );
  }

  /// Navega para o formulário (cadastro ou edição).
  void _navigateToForm(BuildContext context, {Product? product}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ProductFormPage(viewModel: viewModel, product: product),
      ),
    );
  }

  /// Mostra diálogo de confirmação antes de excluir.
  Future<void> _confirmDelete(BuildContext context, Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text('Deseja realmente excluir "${product.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await viewModel.deleteProduct(product.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produto excluído com sucesso!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          ValueListenableBuilder(
            valueListenable: viewModel.state,
            builder: (context, state, _) {
              return Row(
                children: [
                  // Contador de favoritos
                  if (state.favoriteCount > 0)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 18),
                          const SizedBox(width: 2),
                          Text(
                            '${state.favoriteCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  // Botão de filtro de favoritos
                  IconButton(
                    tooltip: state.showOnlyFavorites
                        ? 'Mostrar todos'
                        : 'Mostrar favoritos',
                    icon: Icon(
                      state.showOnlyFavorites ? Icons.star : Icons.star_border,
                      color: state.showOnlyFavorites
                          ? Colors.amber
                          : Colors.white,
                    ),
                    onPressed: viewModel.toggleFavoriteFilter,
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: viewModel.state,
        builder: (context, state, _) {
          // Estado: carregando
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Estado: erro na requisição
          if (state.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    state.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: viewModel.loadProducts,
                    child: const Text('Tentar novamente'),
                  ),
                ],
              ),
            );
          }

          // Estado: lista geral vazia
          if (state.products.isEmpty) {
            return const Center(child: Text('Nenhum produto encontrado'));
          }

          // Estado: filtro de favoritos ativo, mas nenhum favoritado
          if (state.showOnlyFavorites && state.displayedProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum produto favoritado.\nToque na estrela para favoritar!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // Lista de produtos
          return ListView.builder(
            itemCount: state.displayedProducts.length,
            itemBuilder: (context, index) {
              final product = state.displayedProducts[index];
              return ProductCard(
                product: product,
                onTap: () => _navigateToDetail(context, product),
                onEdit: () => _navigateToForm(context, product: product),
                onDelete: () => _confirmDelete(context, product),
                onToggleFavorite: () => viewModel.toggleFavorite(product.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context),
        backgroundColor: Colors.deepPurple,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Novo', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
