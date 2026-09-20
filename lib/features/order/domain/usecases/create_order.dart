import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class CreateOrder implements UseCase<Orders, Orders> {
  final OrderRepository repository;

  CreateOrder(this.repository);

  @override
  Future<Either<Failure, Orders>> call(Orders order) {
    return repository.createOrder(order);
  }
}
