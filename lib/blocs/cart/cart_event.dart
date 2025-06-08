import 'package:equatable/equatable.dart';
import '../../models/product_model.dart';

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddToCart extends CartEvent {
  final ProductModel product;
  final String selectedSize;
  final String selectedColor;

  const AddToCart({
    required this.product,
    required this.selectedSize,
    required this.selectedColor,
  });

  @override
  List<Object?> get props => [product, selectedSize, selectedColor];
}

class RemoveFromCart extends CartEvent {
  final ProductModel product;
  final String selectedSize;
  final String selectedColor;

  const RemoveFromCart({
    required this.product,
    required this.selectedSize,
    required this.selectedColor,
  });

  @override
  List<Object?> get props => [product, selectedSize, selectedColor];
}

class ClearCart extends CartEvent {}

class IncreaseQuantity extends CartEvent {
  final ProductModel product;
  final String selectedSize;
  final String selectedColor;

  const IncreaseQuantity({
    required this.product,
    required this.selectedSize,
    required this.selectedColor,
  });

  @override
  List<Object?> get props => [product, selectedSize, selectedColor];
}

class DecreaseQuantity extends CartEvent {
  final ProductModel product;
  final String selectedSize;
  final String selectedColor;

  const DecreaseQuantity({
    required this.product,
    required this.selectedSize,
    required this.selectedColor,
  });

  @override
  List<Object?> get props => [product, selectedSize, selectedColor];
}
