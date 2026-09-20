import 'dart:convert';

import '../../../../core/database/app_database.dart';
import '../../domain/entities/order.dart';

class OrderModel {
  static Orders fromDrift(OrdersTableData row) {
    List<String> itemsList = [];
    try {
      final decoded = jsonDecode(row.items);
      if (decoded is List) {
        itemsList = decoded.map((e) => e.toString()).toList();
      }
    } catch (_) {}

    return Orders(
      id: row.id,
      customerId: row.customerId,
      items: itemsList,
      status: OrderStatus.fromString(row.status),
      totalAmount: row.totalAmount,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static OrdersTableCompanion toCompanion(Orders order) {
    return OrdersTableCompanion.insert(
      id: order.id,
      customerId: order.customerId,
      items: jsonEncode(order.items),
      status: order.status.name,
      totalAmount: order.totalAmount,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
    );
  }
}
