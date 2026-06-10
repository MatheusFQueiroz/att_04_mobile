/// Entidade de domínio que representa um produto da loja.
class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String image;
  final String category;

  /// Indica se o produto está marcado como favorito pelo usuário.
  bool favorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    this.favorite = false,
  });
}
