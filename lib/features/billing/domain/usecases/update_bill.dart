import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/bill.dart';
import '../repositories/billing_repository.dart';

class UpdateBill implements UseCase<Bill, Bill> {
  final BillingRepository repository;

  UpdateBill(this.repository);

  @override
  Future<Either<Failure, Bill>> call(Bill bill) {
    return repository.updateBill(bill);
  }
}
