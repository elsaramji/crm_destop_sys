import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/order_repository.dart';

class DeleteOrder implements UseCase<void, String> {
  final OrderRepository repository;

  DeleteOrder(this.repository);

  @override
  Future<Either<Failure, void>> call(String orderId) {
    return repository.deleteOrder(orderId);
  }
}
