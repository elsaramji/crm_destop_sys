import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class UpdateCustomer implements UseCase<Customer, Customer> {
  final CustomerRepository repository;

  UpdateCustomer(this.repository);

  @override
  Future<Either<Failure, Customer>> call(Customer customer) {
    return repository.updateCustomer(customer);
  }
}
