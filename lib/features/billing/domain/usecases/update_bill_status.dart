import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/bill.dart';
import '../repositories/billing_repository.dart';

class UpdateBillStatusParams extends Equatable {
  final String billId;
  final BillStatus status;
  final double paidAmount;

  const UpdateBillStatusParams({
    required this.billId,
    required this.status,
    required this.paidAmount,
  });

  @override
  List<Object?> get props => [billId, status, paidAmount];
}

class UpdateBillStatus implements UseCase<void, UpdateBillStatusParams> {
  final BillingRepository repository;

  UpdateBillStatus(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateBillStatusParams params) {
    return repository.updateBillStatus(params.billId, params.status, params.paidAmount);
  }
}
