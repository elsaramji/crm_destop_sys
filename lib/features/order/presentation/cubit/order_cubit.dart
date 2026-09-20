import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/order.dart';
import '../../domain/usecases/create_order.dart';
import '../../domain/usecases/delete_order.dart';
import '../../domain/usecases/get_all_orders.dart';
import '../../domain/usecases/get_orders_by_customer.dart';
import '../../domain/usecases/update_order.dart';
import '../../domain/usecases/update_order_status.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final GetAllOrders _getAllOrders;
  final GetOrdersByCustomer _getOrdersByCustomer;
  final CreateOrder _createOrder;
  final UpdateOrder _updateOrder;
  final UpdateOrderStatus _updateOrderStatus;
  final DeleteOrder _deleteOrder;

  OrderCubit({
    required GetAllOrders getAllOrders,
    required GetOrdersByCustomer getOrdersByCustomer,
    required CreateOrder createOrder,
    required UpdateOrder updateOrder,
    required UpdateOrderStatus updateOrderStatus,
    required DeleteOrder deleteOrder,
  }) : _getAllOrders = getAllOrders,
       _getOrdersByCustomer = getOrdersByCustomer,
       _createOrder = createOrder,
       _updateOrder = updateOrder,
       _updateOrderStatus = updateOrderStatus,
       _deleteOrder = deleteOrder,
       super(const OrderLoading()) {
    loadOrders();
  }

  Future<void> loadOrders() async {
    emit(const OrderLoading());
    final result = await _getAllOrders(const NoParams());
    result.fold(
      (failure) => emit(const OrderLoaded(allOrders: [])),
      (orders) => emit(OrderLoaded(allOrders: orders)),
    );
  }

  Future<void> createOrder(Orders order) async {
    final result = await _createOrder(order);
    result.fold((failure) {}, (Orders saved) {
      if (state is OrderLoaded) {
        final current = state as OrderLoaded;
        final List<Orders> updated = [saved, ...current.allOrders];
        emit(current.copyWith(allOrders: updated));
      } else {
        loadOrders();
      }
    });
  }

  Future<void> updateOrder(Orders order) async {
    final result = await _updateOrder(order);
    result.fold((failure) {}, (Orders saved) {
      if (state is OrderLoaded) {
        final current = state as OrderLoaded;
        final updated = current.allOrders
            .map((o) => o.id == saved.id ? saved : o)
            .toList();
        emit(current.copyWith(allOrders: updated));
      } else {
        loadOrders();
      }
    });
  }

  Future<void> deleteOrder(String orderId) async {
    final result = await _deleteOrder(orderId);
    result.fold((failure) {}, (_) {
      if (state is OrderLoaded) {
        final current = state as OrderLoaded;
        final updated = current.allOrders
            .where((o) => o.id != orderId)
            .toList();
        emit(current.copyWith(allOrders: updated));
      }
    });
  }

  Future<void> updateOrderStatus(String orderId, OrderStatus newStatus) async {
    final result = await _updateOrderStatus(
      UpdateOrderStatusParams(orderId: orderId, status: newStatus),
    );
    result.fold((failure) {}, (_) {
      if (state is OrderLoaded) {
        final current = state as OrderLoaded;
        final updated = current.allOrders.map((o) {
          if (o.id == orderId) {
            return o.copyWith(status: newStatus, updatedAt: DateTime.now());
          }
          return o;
        }).toList();
        emit(current.copyWith(allOrders: updated));
      } else {
        loadOrders();
      }
    });
  }

  void filterByStatus(OrderStatus? status) {
    if (state is! OrderLoaded) return;
    final current = state as OrderLoaded;
    emit(OrderLoaded(allOrders: current.allOrders, statusFilter: status));
  }

  List<Orders> getOrdersForCustomer(String customerId) {
    if (state is! OrderLoaded) return [];
    final current = state as OrderLoaded;
    return current.allOrders.where((o) => o.customerId == customerId).toList();
  }
}
