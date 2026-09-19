import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/mock/mock_data.dart';
import '../../domain/entities/order.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  OrderCubit() : super(const OrderLoading()) {
    loadOrders();
  }

  void loadOrders() {
    emit(OrderLoaded(
      allOrders: List<Order>.from(MockData.initialOrders),
    ));
  }

  void createOrder(Order order) {
    if (state is! OrderLoaded) return;
    final current = state as OrderLoaded;
    final updated = [order, ...current.allOrders];
    emit(current.copyWith(allOrders: updated));
  }

  void updateOrder(Order order) {
    if (state is! OrderLoaded) return;
    final current = state as OrderLoaded;
    final updated = current.allOrders.map((o) => o.id == order.id ? order : o).toList();
    emit(current.copyWith(allOrders: updated));
  }

  void deleteOrder(String orderId) {
    if (state is! OrderLoaded) return;
    final current = state as OrderLoaded;
    final updated = current.allOrders.where((o) => o.id != orderId).toList();
    emit(current.copyWith(allOrders: updated));
  }

  void updateOrderStatus(String orderId, OrderStatus newStatus) {
    if (state is! OrderLoaded) return;
    final current = state as OrderLoaded;
    final updated = current.allOrders.map((o) {
      if (o.id == orderId) {
        return o.copyWith(status: newStatus, updatedAt: DateTime.now());
      }
      return o;
    }).toList();
    emit(current.copyWith(allOrders: updated));
  }

  void filterByStatus(OrderStatus? status) {
    if (state is! OrderLoaded) return;
    final current = state as OrderLoaded;
    emit(current.copyWith(statusFilter: status));
  }

  List<Order> getOrdersForCustomer(String customerId) {
    if (state is! OrderLoaded) return [];
    final current = state as OrderLoaded;
    return current.allOrders.where((o) => o.customerId == customerId).toList();
  }
}
