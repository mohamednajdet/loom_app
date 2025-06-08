import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:dio/dio.dart';
import '../../models/product_model.dart';
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<LoadProducts>(_onLoadProducts);
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<HomeState> emit) async {
    emit(HomeLoading());

    try {
      final dio = Dio();
      final response = await dio.get('http://10.0.2.2:5000/api/products');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = response.data;

        final List<ProductModel> products = jsonList
            .map((json) => ProductModel.fromJson(json))
            .toList();

        emit(HomeLoaded(products));
      } else {
        emit(HomeError('فشل تحميل المنتجات'));
      }
    } catch (e) {
      emit(HomeError('خطأ في الاتصال بالسيرفر: $e'));
    }
  }
}
