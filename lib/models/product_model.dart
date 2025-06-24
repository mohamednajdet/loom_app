import 'package:equatable/equatable.dart';

class ProductModel extends Equatable {
  final String id;
  final String name;
  final String gender;
  final String type; // ← بدل category
  final int price;
  final int discount;
  final int? discountedPrice;
  final List<String> sizes;
  final List<String> colors;
  final List<String> images;
  final bool? isFavorite;

  const ProductModel({
    required this.id,
    required this.name,
    required this.gender,
    required this.type, // ← بدل category
    required this.price,
    required this.discount,
    this.discountedPrice,
    required this.sizes,
    required this.colors,
    required this.images,
    this.isFavorite,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      gender: json['gender'] ?? '',
      type: json['type'] ?? '', // ← بدل category
      price: json['price'] ?? 0,
      discount: json['discount'] ?? 0,
      discountedPrice: json['discountedPrice'],
      sizes: List<String>.from(json['sizes'] ?? []),
      colors: List<String>.from(json['colors'] ?? []),
      images: List<String>.from(json['images'] ?? []),
      isFavorite: json['isFavorite'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'gender': gender,
      'type': type, // ← بدل category
      'price': price,
      'discount': discount,
      'discountedPrice': discountedPrice,
      'sizes': sizes,
      'colors': colors,
      'images': images,
      'isFavorite': isFavorite,
    };
  }

  @override
  List<Object?> get props => [
        id,
        name,
        gender,
        type, // ← بدل category
        price,
        discount,
        discountedPrice,
        sizes,
        colors,
        images,
        isFavorite,
      ];
}
