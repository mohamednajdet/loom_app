import 'package:equatable/equatable.dart';
import '../../models/product_model.dart';

class FavoriteState extends Equatable {
  final List<String> favoriteProductIds;
  final List<ProductModel> favoriteProducts;
  final bool isLoading;
  final String? error;

  const FavoriteState({
    required this.favoriteProductIds,
    required this.favoriteProducts,
    this.isLoading = false,
    this.error,
  });

  FavoriteState copyWith({
    List<String>? favoriteProductIds,
    List<ProductModel>? favoriteProducts,
    bool? isLoading,
    String? error,
  }) {
    return FavoriteState(
      favoriteProductIds: favoriteProductIds ?? this.favoriteProductIds,
      favoriteProducts: favoriteProducts ?? this.favoriteProducts,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        favoriteProductIds,
        favoriteProducts,
        isLoading,
        error,
      ];
}
