import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class GetCustomerById implements UseCase<Customer, String> {
  final CustomerRepository repository;

  GetCustomerById(this.repository);

  @override
  Future<Either<Failure, Customer>> call(String id) {
    return repository.getCustomerById(id);
  }
}
