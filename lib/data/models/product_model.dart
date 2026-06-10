/// Modelo de dados para serialização/deserialização de produtos (DummyJSON).
class ProductModel {
  final int id;
  final String title;
  final String description;
  final double price;
  final String thumbnail;
  final String category;
  final int stock;
  final double rating;

  ProductModel({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.thumbnail,
    required this.category,
    this.stock = 0,
    this.rating = 0.0,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      price: (json['price'] as num).toDouble(),
      thumbnail: json['thumbnail'] as String? ?? '',
      category: json['category'] as String? ?? '',
      stock: json['stock'] as int? ?? 0,
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'thumbnail': thumbnail,
      'category': category,
      'stock': stock,
      'rating': rating,
    };
  }
}
