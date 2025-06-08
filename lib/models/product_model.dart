import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String id;
  final String name;
  final String gender;
  final String category;
  final int price;
  final int discount;
  final List<String> sizes;
  final List<String> colors;
  final List<String> images;

  const ProductModel({
    required this.id,
    required this.name,
    required this.gender,
    required this.category,
    required this.price,
    required this.discount,
    required this.sizes,
    required this.colors,
    required this.images,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      category: json['category'] ?? '',
      price: json['price'] ?? 0,
      discount: json['discount'] ?? 0,
      sizes: List<String>.from(json['sizes'] ?? []),
      colors: List<String>.from(json['colors'] ?? []),
      images: List<String>.from(json['images'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'gender': gender,
      'category': category,
      'price': price,
      'discount': discount,
      'sizes': sizes,
      'colors': colors,
      'images': images,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        gender,
        category,
        price,
        discount,
        sizes,
        colors,
        images,
      ];
}
