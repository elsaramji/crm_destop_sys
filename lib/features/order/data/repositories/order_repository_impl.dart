import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/order.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_local_datasource.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderLocalDatasource localDatasource;

  OrderRepositoryImpl(this.localDatasource);

  @override
  Future<Either<Failure, List<Orders>>> getAllOrders() async {
    try {
      final orders = await localDatasource.getAllOrders();
      return Right(orders);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Orders>>> getOrdersByCustomer(String customerId) async {
    try {
      final orders = await localDatasource.getOrdersByCustomer(customerId);
      return Right(orders);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Orders>> createOrder(Orders order) async {
    try {
      final created = await localDatasource.createOrder(order);
      return Right(created);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Orders>> updateOrder(Orders order) async {
    try {
      final updated = await localDatasource.updateOrder(order);
      return Right(updated);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      await localDatasource.updateOrderStatus(orderId, status);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteOrder(String orderId) async {
    try {
      await localDatasource.deleteOrder(orderId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
