import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/bill.dart';
import '../repositories/billing_repository.dart';

class GetAllBills implements UseCase<List<Bill>, NoParams> {
  final BillingRepository repository;

  GetAllBills(this.repository);

  @override
  Future<Either<Failure, List<Bill>>> call(NoParams params) {
    return repository.getAllBills();
  }
}
