import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/bill.dart';

abstract class BillingRepository {
  Future<Either<Failure, List<Bill>>> getAllBills();
  Future<Either<Failure, List<Bill>>> getBillsByCustomer(String customerId);
  Future<Either<Failure, Bill>> recordBill(Bill bill);
  Future<Either<Failure, Bill>> updateBill(Bill bill);
  Future<Either<Failure, void>> updateBillStatus(String billId, BillStatus status, double paidAmount);
  Future<Either<Failure, void>> deleteBill(String billId);
}
