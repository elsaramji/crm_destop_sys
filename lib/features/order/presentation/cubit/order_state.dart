import 'package:equatable/equatable.dart';

import '../../domain/entities/order.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrderLoaded extends OrderState {
  final List<Orders> allOrders;
  final OrderStatus? statusFilter;

  const OrderLoaded({required this.allOrders, this.statusFilter});

  List<Orders> get filteredOrders {
    if (statusFilter == null) return allOrders;
    return allOrders.where((o) => o.status == statusFilter).toList();
  }

  OrderLoaded copyWith({
    List<Orders>? allOrders,
    OrderStatus? statusFilter,
    bool clearStatusFilter = false,
  }) {
    return OrderLoaded(
      allOrders: allOrders ?? this.allOrders,
      statusFilter: clearStatusFilter
          ? null
          : (statusFilter ?? this.statusFilter),
    );
  }

  @override
  List<Object?> get props => [allOrders, statusFilter];
}
