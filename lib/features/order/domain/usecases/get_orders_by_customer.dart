import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetOrdersByCustomer implements UseCase<List<Orders>, String> {
  final OrderRepository repository;

  GetOrdersByCustomer(this.repository);

  @override
  Future<Either<Failure, List<Orders>>> call(String customerId) {
    return repository.getOrdersByCustomer(customerId);
  }
}
