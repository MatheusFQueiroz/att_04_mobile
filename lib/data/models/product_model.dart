/// Modelo de dados para serialização/deserialização de produtos.
///
/// Separa a camada de dados da entidade de domínio, permitindo
/// flexibilidade na estrutura da API vs. estrutura interna.
class ProductModel {
  final int id;
  final String title;
  final String description;
  final double price;
  final String image;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.image,
  });

  /// Cria um ProductModel a partir de um JSON.
  ///
  /// [json] - Map contendo os dados do produto da API.
  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'],
      title: json['title'],
      description: json['description'] ?? '',
      price: json['price'].toDouble(),
      image: json['image'],
    );
  }

  /// Converte o ProductModel para JSON.
  ///
  /// Retorna um Map<String, dynamic> pronto para serialização.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'image': image,
    };
  }
}
