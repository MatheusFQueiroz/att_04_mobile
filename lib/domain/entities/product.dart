/// Entidade de domínio que representa um produto da loja.
class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String thumbnail;
  final String category;
  final int stock;
  final double rating;

  /// Indica se o produto está marcado como favorito pelo usuário.
  bool favorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.thumbnail,
    required this.category,
    this.stock = 0,
    this.rating = 0.0,
    this.favorite = false,
  });
}
