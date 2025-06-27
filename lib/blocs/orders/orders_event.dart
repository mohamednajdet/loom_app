import 'package:equatable/equatable.dart';

abstract class OrdersEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrdersEvent {}

class RefreshOrders extends OrdersEvent {}

class FilterOrdersByStatus extends OrdersEvent {
  final String status;

  FilterOrdersByStatus(this.status);

  @override
  List<Object?> get props => [status];
}
