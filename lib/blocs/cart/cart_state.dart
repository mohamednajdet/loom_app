import 'package:equatable/equatable.dart';
import '../../models/product_model.dart';

class CartItem extends Equatable {
  final ProductModel product;
  final String selectedSize;
  final String selectedColor;
  final int quantity;

  const CartItem({
    required this.product,
    required this.selectedSize,
    required this.selectedColor,
    this.quantity = 1,
  });

  CartItem copyWith({int? quantity}) {
    return CartItem(
      product: product,
      selectedSize: selectedSize,
      selectedColor: selectedColor,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(),
      'selectedSize': selectedSize,
      'selectedColor': selectedColor,
      'quantity': quantity,
    };
  }

  @override
  List<Object?> get props => [product.id, selectedSize, selectedColor, quantity];
}

class CartState extends Equatable {
  final List<CartItem> items;
  final String? selectedAddressLabel; // 🆕 العنوان المختار

  const CartState({
    this.items = const [],
    this.selectedAddressLabel,
  });

  CartState copyWith({
    List<CartItem>? items,
    String? selectedAddressLabel,
  }) {
    return CartState(
      items: items ?? this.items,
      selectedAddressLabel: selectedAddressLabel ?? this.selectedAddressLabel,
    );
  }

  List<CartItem> get cartItems => items;

  @override
  List<Object?> get props => [items, selectedAddressLabel];
}