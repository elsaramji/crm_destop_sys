import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/billing_repository.dart';

class DeleteBill implements UseCase<void, String> {
  final BillingRepository repository;

  DeleteBill(this.repository);

  @override
  Future<Either<Failure, void>> call(String billId) {
    return repository.deleteBill(billId);
  }
}
