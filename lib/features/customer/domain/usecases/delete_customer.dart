import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/customer_repository.dart';

class DeleteCustomer implements UseCase<void, String> {
  final CustomerRepository repository;

  DeleteCustomer(this.repository);

  @override
  Future<Either<Failure, void>> call(String id) {
    return repository.deleteCustomer(id);
  }
}
