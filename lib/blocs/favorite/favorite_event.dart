import 'package:equatable/equatable.dart';

abstract class FavoriteEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadFavorites extends FavoriteEvent {}

class ToggleFavorite extends FavoriteEvent {
  final String productId;

  ToggleFavorite(this.productId);

  @override
  List<Object?> get props => [productId];
}
