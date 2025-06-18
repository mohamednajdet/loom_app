import 'package:flutter_bloc/flutter_bloc.dart';
import 'favorite_event.dart';
import 'favorite_state.dart';
import '../../services/api_service_dio.dart';
import '../../models/product_model.dart';

class FavoriteBloc extends Bloc<FavoriteEvent, FavoriteState> {
  FavoriteBloc()
      : super(const FavoriteState(favoriteProductIds: [], favoriteProducts: [])) {
    on<LoadFavorites>(_onLoadFavorites);
    on<ToggleFavorite>(_onToggleFavorite);
  }

  Future<void> _onLoadFavorites(
    LoadFavorites event,
    Emitter<FavoriteState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));

    try {
      final products = await ApiServiceDio.getFavoriteProducts();
      final ids = products.map((p) => p.id).toList();

      emit(state.copyWith(
        favoriteProducts: products,
        favoriteProductIds: ids,
        isLoading: false,
        error: null,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<FavoriteState> emit,
  ) async {
    final isFav = state.favoriteProductIds.contains(event.productId);
    final updatedIds = List<String>.from(state.favoriteProductIds);
    final updatedProducts = List<ProductModel>.from(state.favoriteProducts);

    if (isFav) {
      // 🟥 Optimistic remove
      updatedIds.remove(event.productId);
      updatedProducts.removeWhere((p) => p.id == event.productId);
      emit(state.copyWith(
        favoriteProductIds: updatedIds,
        favoriteProducts: updatedProducts,
        error: null,
      ));

      try {
        await ApiServiceDio.removeFromFavorites(event.productId);
      } catch (e) {
        // rollback
        updatedIds.add(event.productId);
        emit(state.copyWith(
          favoriteProductIds: updatedIds,
          favoriteProducts: updatedProducts,
          error: 'فشل حذف المنتج من المفضلة',
        ));
      }
    } else {
      // ✅ Optimistic add (مؤقت بدون تفاصيل المنتج)
      updatedIds.add(event.productId);
      emit(state.copyWith(
        favoriteProductIds: updatedIds,
        error: null,
      ));

      try {
        await ApiServiceDio.addToFavorites(event.productId);
        final newProduct = await ApiServiceDio.getProductById(event.productId);

        updatedProducts.add(newProduct);
        emit(state.copyWith(
          favoriteProductIds: updatedIds,
          favoriteProducts: updatedProducts,
          error: null,
        ));
      } catch (e) {
        // rollback
        updatedIds.remove(event.productId);
        emit(state.copyWith(
          favoriteProductIds: updatedIds,
          favoriteProducts: updatedProducts,
          error: 'فشل إضافة المنتج للمفضلة',
        ));
      }
    }
  }
}
