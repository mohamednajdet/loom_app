import 'package:equatable/equatable.dart';
import '../../models/order_model.dart';

abstract class OrdersState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoaded extends OrdersState {
  final List<OrderModel> orders;          // كل الطلبات
  final String currentStatus;             // فلترة حالية (all, pending...)

  OrdersLoaded(
    this.orders, {
    this.currentStatus = 'all',
  });

  // إرجاع لائحة مصفَّاة عند الحاجة
  List<OrderModel> get filtered => currentStatus == 'all'
      ? orders
      : orders.where((o) => o.status == currentStatus).toList();

  @override
  List<Object?> get props => [orders, currentStatus];
}

class OrdersError extends OrdersState {
  final String message;
  OrdersError(this.message);

  @override
  List<Object?> get props => [message];
}
