import 'package:drift/drift.dart';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/order.dart';
import '../models/order_model.dart';

abstract class OrderLocalDatasource {
  Future<List<Orders>> getAllOrders();
  Future<List<Orders>> getOrdersByCustomer(String customerId);
  Future<Orders> createOrder(Orders order);
  Future<Orders> updateOrder(Orders order);
  Future<void> updateOrderStatus(String orderId, OrderStatus status);
  Future<void> deleteOrder(String orderId);
}

class OrderLocalDatasourceImpl implements OrderLocalDatasource {
  final AppDatabase database;

  OrderLocalDatasourceImpl(this.database);

  @override
  Future<List<Orders>> getAllOrders() async {
    final rows = await (database.select(
      database.ordersTable,
    )..orderBy([(t) => OrderingTerm.desc(t.createdAt)])).get();
    return rows.map(OrderModel.fromDrift).toList();
  }

  @override
  Future<List<Orders>> getOrdersByCustomer(String customerId) async {
    final rows =
        await (database.select(database.ordersTable)
              ..where((t) => t.customerId.equals(customerId))
              ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
            .get();
    return rows.map(OrderModel.fromDrift).toList();
  }

  @override
  Future<Orders> createOrder(Orders order) async {
    await database
        .into(database.ordersTable)
        .insert(OrderModel.toCompanion(order));
    return order;
  }

  @override
  Future<Orders> updateOrder(Orders order) async {
    await (database.update(database.ordersTable)
          ..where((t) => t.id.equals(order.id)))
        .write(OrderModel.toCompanion(order));
    return order;
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    await (database.update(
      database.ordersTable,
    )..where((t) => t.id.equals(orderId))).write(
      OrdersTableCompanion(
        status: Value(status.name),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<void> deleteOrder(String orderId) async {
    await (database.delete(
      database.ordersTable,
    )..where((t) => t.id.equals(orderId))).go();
  }
}
