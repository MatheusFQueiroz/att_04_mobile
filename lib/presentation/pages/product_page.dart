import 'package:flutter/material.dart';
import '../viewmodels/product_viewmodel.dart';

/// Página principal que exibe a lista de produtos com suporte a favoritos.
///
/// Funcionalidades:
/// - Exibe contador de favoritos na AppBar
/// - Botão de filtro para alternar entre todos/favoritos
/// - Ícone de estrela em cada item para marcar/desmarcar favorito
/// - Destaque visual (borda dourada) nos produtos favoritados
/// - Mensagem de estado vazio quando filtro ativo e sem favoritos
class ProductPage extends StatelessWidget {
  final ProductViewModel viewModel;

  const ProductPage({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Produtos'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          // Escuta o estado para atualizar contador e botão de filtro
          ValueListenableBuilder(
            valueListenable: viewModel.state,
            builder: (context, state, _) {
              return Row(
                children: [
                  // Contador de favoritos — exibe estrela + número
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
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Botão de filtro: alterna entre todos / só favoritos
                  IconButton(
                    tooltip: state.showOnlyFavorites
                        ? 'Mostrar todos os produtos'
                        : 'Mostrar apenas favoritos',
                    icon: Icon(
                      state.showOnlyFavorites
                          ? Icons
                                .star // filtro ativo: estrela preenchida
                          : Icons.star_border, // filtro inativo: estrela vazia
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

          // Estado: filtro de favoritos ativo, mas nenhum produto favoritado
          if (state.showOnlyFavorites && state.displayedProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star_border, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhum produto favoritado ainda.\nToque na estrela (☆) para favoritar!',
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Estado: lista de produtos (todos ou filtrados)
          return ListView.builder(
            itemCount: state.displayedProducts.length,
            itemBuilder: (context, index) {
              final product = state.displayedProducts[index];
              return _ProductCard(
                product: product,
                onToggleFavorite: () => viewModel.toggleFavorite(product.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: viewModel.loadProducts,
        backgroundColor: Colors.deepPurple,
        tooltip: 'Atualizar produtos',
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
    );
  }
}

/// Widget de card para exibir um produto individual.
///
/// Exibe destaque visual (borda dourada) quando [product.favorite] é true
/// e um ícone de estrela clicável para alternar o estado de favorito.
class _ProductCard extends StatelessWidget {
  final dynamic product; // Product entity
  final VoidCallback onToggleFavorite;

  const _ProductCard({required this.product, required this.onToggleFavorite});

  @override
  Widget build(BuildContext context) {
    final isFavorite = product.favorite as bool;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      // Borda dourada para produtos favoritados
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: isFavorite
            ? const BorderSide(color: Colors.amber, width: 2)
            : BorderSide.none,
      ),
      // Leve fundo amarelado para produtos favoritados
      color: isFavorite ? Colors.amber.shade50 : null,
      child: ListTile(
        // Imagem do produto
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: Image.network(
            product.image as String,
            width: 50,
            height: 50,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 50,
                height: 50,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              );
            },
          ),
        ),

        // Título do produto
        title: Text(
          product.title as String,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

        // Preço do produto
        subtitle: Text(
          'R\$ ${(product.price as double).toStringAsFixed(2)}',
          style: TextStyle(
            color: Colors.green[700],
            fontWeight: FontWeight.w600,
          ),
        ),

        // Ícone de favorito: estrela preenchida (★) ou vazia (☆)
        trailing: IconButton(
          tooltip: isFavorite
              ? 'Remover dos favoritos'
              : 'Adicionar aos favoritos',
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite ? Colors.amber : Colors.grey,
            size: 28,
          ),
          onPressed: onToggleFavorite,
        ),
      ),
    );
  }
}
