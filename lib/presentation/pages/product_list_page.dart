import 'package:flutter/material.dart';
import '../../core/session/session_controller.dart';
import '../../domain/entities/product.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/product_viewmodel.dart';
import '../widgets/product_card.dart';
import 'login_page.dart';
import 'product_detail_page.dart';
import 'product_form_page.dart';

/// Tela principal com lista de produtos, favoritos, CRUD e logout.
class ProductListPage extends StatelessWidget {
  final ProductViewModel viewModel;
  final AuthViewModel authViewModel;

  const ProductListPage({
    super.key,
    required this.viewModel,
    required this.authViewModel,
  });

  void _navigateToDetail(BuildContext context, Product product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductDetailPage(
          productId: product.id,
          repository: viewModel.repository,
        ),
      ),
    );
  }

  void _navigateToForm(BuildContext context, {Product? product}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProductFormPage(viewModel: viewModel, product: product),
      ),
    );
  }

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

  void _logout(BuildContext context) {
    authViewModel.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginPage(
          authViewModel: authViewModel,
          productViewModel: viewModel,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = SessionController.instance.user;

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
                  // Nome do usuário logado
                  if (user != null)
                    Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Center(
                        child: Text(
                          user.firstName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
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
                  // Filtro favoritos
                  IconButton(
                    tooltip: state.showOnlyFavorites
                        ? 'Mostrar todos'
                        : 'Mostrar favoritos',
                    icon: Icon(
                      state.showOnlyFavorites ? Icons.star : Icons.star_border,
                      color: state.showOnlyFavorites ? Colors.amber : Colors.white,
                    ),
                    onPressed: viewModel.toggleFavoriteFilter,
                  ),
                  // Logout
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    tooltip: 'Sair',
                    onPressed: () => _logout(context),
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
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

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

          if (state.products.isEmpty) {
            return const Center(child: Text('Nenhum produto encontrado'));
          }

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
