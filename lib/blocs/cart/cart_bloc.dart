import 'package:flutter_bloc/flutter_bloc.dart';
import 'cart_event.dart';
import 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  CartBloc() : super(const CartState()) {
    on<AddToCart>(_onAddToCart);
    on<RemoveFromCart>(_onRemoveFromCart);
    on<ClearCart>(_onClearCart);
    on<IncreaseQuantity>(_onIncreaseQuantity);
    on<DecreaseQuantity>(_onDecreaseQuantity);
  }

  void _onAddToCart(AddToCart event, Emitter<CartState> emit) {
    final existingItemIndex = state.items.indexWhere(
      (item) =>
          item.product.id == event.product.id &&
          item.selectedSize == event.selectedSize &&
          item.selectedColor == event.selectedColor,
    );

    if (existingItemIndex != -1) {
      final updatedItems = List<CartItem>.from(state.items);
      final updatedItem = updatedItems[existingItemIndex]
          .copyWith(quantity: updatedItems[existingItemIndex].quantity + 1);
      updatedItems[existingItemIndex] = updatedItem;
      emit(state.copyWith(items: updatedItems));
    } else {
      final newItem = CartItem(
        product: event.product,
        selectedSize: event.selectedSize,
        selectedColor: event.selectedColor,
        quantity: 1,
      );
      final updatedItems = List<CartItem>.from(state.items)..add(newItem);
      emit(state.copyWith(items: updatedItems));
    }
  }

  void _onRemoveFromCart(RemoveFromCart event, Emitter<CartState> emit) {
    final updatedItems = state.items.where((item) {
      return item.product.id != event.product.id ||
          item.selectedSize != event.selectedSize ||
          item.selectedColor != event.selectedColor;
    }).toList();

    emit(state.copyWith(items: updatedItems));
  }

  void _onClearCart(ClearCart event, Emitter<CartState> emit) {
    emit(const CartState(items: []));
  }

  void _onIncreaseQuantity(IncreaseQuantity event, Emitter<CartState> emit) {
    final updatedItems = state.items.map((item) {
      if (item.product.id == event.product.id &&
          item.selectedSize == event.selectedSize &&
          item.selectedColor == event.selectedColor) {
        return item.copyWith(quantity: item.quantity + 1);
      }
      return item;
    }).toList();

    emit(state.copyWith(items: updatedItems));
  }

  void _onDecreaseQuantity(DecreaseQuantity event, Emitter<CartState> emit) {
    final updatedItems = state.items.map((item) {
      if (item.product.id == event.product.id &&
          item.selectedSize == event.selectedSize &&
          item.selectedColor == event.selectedColor &&
          item.quantity > 1) {
        return item.copyWith(quantity: item.quantity - 1);
      }
      return item;
    }).toList();

    emit(state.copyWith(items: updatedItems));
  }
}
