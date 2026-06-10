import 'package:flutter_test/flutter_test.dart';
import 'package:att_04_mobile_02/data/models/product_model.dart';

void main() {
  group('ProductModel.fromJson (DummyJSON format)', () {
    test('parses thumbnail, stock, rating fields', () {
      final json = {
        'id': 1,
        'title': 'iPhone 9',
        'description': 'An apple mobile phone',
        'price': 549,
        'thumbnail': 'https://cdn.dummyjson.com/thumbnail.jpg',
        'category': 'smartphones',
        'stock': 94,
        'rating': 4.69,
      };
      final model = ProductModel.fromJson(json);
      expect(model.thumbnail, 'https://cdn.dummyjson.com/thumbnail.jpg');
      expect(model.stock, 94);
      expect(model.rating, 4.69);
    });

    test('converts integer price to double', () {
      final json = {
        'id': 1,
        'title': 'Test',
        'description': '',
        'price': 549,
        'thumbnail': 'url',
        'category': 'test',
        'stock': 0,
        'rating': 0.0,
      };
      final model = ProductModel.fromJson(json);
      expect(model.price, 549.0);
      expect(model.price, isA<double>());
    });

    test('description defaults to empty string when absent', () {
      final json = {
        'id': 1,
        'title': 'Test',
        'price': 10.0,
        'thumbnail': 'url',
        'category': 'test',
        'stock': 0,
        'rating': 0.0,
      };
      final model = ProductModel.fromJson(json);
      expect(model.description, '');
    });

    test('toJson includes thumbnail, stock, rating', () {
      final model = ProductModel(
        id: 1, title: 'T', description: 'D', price: 9.99,
        thumbnail: 'thumb.jpg', category: 'cat', stock: 5, rating: 4.0,
      );
      final json = model.toJson();
      expect(json['thumbnail'], 'thumb.jpg');
      expect(json['stock'], 5);
      expect(json['rating'], 4.0);
      expect(json.containsKey('image'), false);
    });
  });
}
