import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

class GetAllOrders implements UseCase<List<Orders>, NoParams> {
  final OrderRepository repository;

  GetAllOrders(this.repository);

  @override
  Future<Either<Failure, List<Orders>>> call(NoParams params) {
    return repository.getAllOrders();
  }
}
