import 'package:fpdart/fpdart.dart' hide Order;

import '../../../../core/error/failures.dart';
import '../entities/order.dart';

abstract class OrderRepository {
  Future<Either<Failure, List<Orders>>> getAllOrders();
  Future<Either<Failure, List<Orders>>> getOrdersByCustomer(String customerId);
  Future<Either<Failure, Orders>> createOrder(Orders order);
  Future<Either<Failure, Orders>> updateOrder(Orders order);
  Future<Either<Failure, void>> updateOrderStatus(
    String orderId,
    OrderStatus status,
  );
  Future<Either<Failure, void>> deleteOrder(String orderId);
}
