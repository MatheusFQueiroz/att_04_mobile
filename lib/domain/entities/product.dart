/// Entidade de domínio que representa um produto da loja.
///
/// O campo [favorite] é mutável (não-final) para permitir o toggle
/// de favorito sem precisar recriar o objeto inteiro.
class Product {
  final int id;
  final String title;
  final String description;
  final double price;
  final String image;

  /// Indica se o produto está marcado como favorito pelo usuário.
  /// Mutável para permitir alteração via [ProductViewModel.toggleFavorite].
  bool favorite;

  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
    this.favorite = false, // padrão: não favoritado
  });
}
