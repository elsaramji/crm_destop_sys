import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/customer.dart';
import '../repositories/customer_repository.dart';

class SearchCustomers implements UseCase<List<Customer>, String> {
  final CustomerRepository repository;

  SearchCustomers(this.repository);

  @override
  Future<Either<Failure, List<Customer>>> call(String query) {
    return repository.searchCustomers(query);
  }
}
