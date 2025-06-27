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
  final List<String>? categoryTypes; // ✅ تم إضافته هنا
  final double? minPrice;
  final double? maxPrice;

  const SearchProductsWithFilters({
    required this.query,
    this.types,
    this.genders,
    this.sizes,
    this.categoryTypes, // ✅ هنا أيضاً
    this.minPrice,
    this.maxPrice,
  });

  @override
  List<Object?> get props => [
        query,
        types ?? [],
        genders ?? [],
        sizes ?? [],
        categoryTypes ?? [], // ✅ إضافة في props
        minPrice ?? 0.0,
        maxPrice ?? 0.0,
      ];
}
