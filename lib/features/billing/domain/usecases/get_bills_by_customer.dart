import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/bill.dart';
import '../repositories/billing_repository.dart';

class GetBillsByCustomer implements UseCase<List<Bill>, String> {
  final BillingRepository repository;

  GetBillsByCustomer(this.repository);

  @override
  Future<Either<Failure, List<Bill>>> call(String customerId) {
    return repository.getBillsByCustomer(customerId);
  }
}
