import 'package:equatable/equatable.dart';

abstract class SearchEvent extends Equatable {
  const SearchEvent();

  @override
  List<Object?> get props => [];
}

class SearchProducts extends SearchEvent {
  final String query;
  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

class SearchProductsWithFilters extends SearchEvent {
  final String query;
  final List<String>? types;
  final List<String>? genders;
  final List<String>? sizes;
  final double? minPrice;
  final double? maxPrice;

  const SearchProductsWithFilters({
    required this.query,
    this.types,
    this.genders,
    this.sizes,
    this.minPrice,
    this.maxPrice,
  });

  @override
  List<Object?> get props => [
        query,
        types ?? [],
        genders ?? [],
        sizes ?? [],
        minPrice ?? 0.0,
        maxPrice ?? 0.0,
      ];
}
