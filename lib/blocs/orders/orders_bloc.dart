import 'package:flutter_bloc/flutter_bloc.dart';
import 'orders_event.dart';
import 'orders_state.dart';
import '../../services/api_service_dio.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc() : super(OrdersInitial()) {
    // تحميل الطلبات عند أول فتح
    on<LoadOrders>(_onLoadOrders);

    // سحب-للتحديث (RefreshIndicator)
    on<RefreshOrders>(_onRefreshOrders);
  }

  // -------------------------------------------------------------------------
  Future<void> _onLoadOrders(
      LoadOrders event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());
    await _fetchAndEmitOrders(emit);
  }

  Future<void> _onRefreshOrders(
      RefreshOrders event, Emitter<OrdersState> emit) async {
    emit(OrdersLoading());                         // مؤشر دوران خفيف
    await _fetchAndEmitOrders(emit);
  }

  Future<void> _fetchAndEmitOrders(Emitter<OrdersState> emit) async {
    try {
      final orders = await ApiServiceDio.fetchUserOrders();
      emit(OrdersLoaded(orders));
    } catch (e) {
      emit(OrdersError(e.toString()));
    }
  }
}
