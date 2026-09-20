import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class GetCustomers implements UseCase<List<Customer>, NoParams> {
  final CustomerRepository repository;

  GetCustomers(this.repository);

  @override
  Future<Either<Failure, List<Customer>>> call(NoParams params) {
    return repository.getCustomers();
  }
}
