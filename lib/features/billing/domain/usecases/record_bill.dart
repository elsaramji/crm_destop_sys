import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/bill.dart';
import '../repositories/billing_repository.dart';

class RecordBill implements UseCase<Bill, Bill> {
  final BillingRepository repository;

  RecordBill(this.repository);

  @override
  Future<Either<Failure, Bill>> call(Bill bill) {
    return repository.recordBill(bill);
  }
}
