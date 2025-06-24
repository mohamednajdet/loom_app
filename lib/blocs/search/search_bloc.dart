import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service_dio.dart';
import 'search_event.dart';
import 'search_state.dart';


class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc() : super(SearchInitial()) {
    on<SearchProducts>(_onSearchProducts);
    on<SearchProductsWithFilters>(_onSearchWithFilters);
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();

    if (query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    try {
      final results = await ApiServiceDio.searchProducts(query: query);
      emit(SearchLoaded(results));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }

  Future<void> _onSearchWithFilters(
    SearchProductsWithFilters event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query.trim();

    final bool noFilters = query.isEmpty &&
        (event.types?.isEmpty ?? true) &&
        (event.genders?.isEmpty ?? true) &&
        (event.sizes?.isEmpty ?? true) &&
        event.minPrice == null &&
        event.maxPrice == null;

    if (noFilters) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());

    try {
      final results = await ApiServiceDio.searchProducts(
        query: query,
        types: event.types,
        genders: event.genders,
        sizes: event.sizes,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
      );
      emit(SearchLoaded(results));
    } catch (e) {
      emit(SearchError(e.toString()));
    }
  }
}
