import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/bill.dart';
import '../../domain/repositories/billing_repository.dart';
import '../datasources/billing_local_datasource.dart';

class BillingRepositoryImpl implements BillingRepository {
  final BillingLocalDatasource localDatasource;

  BillingRepositoryImpl(this.localDatasource);

  @override
  Future<Either<Failure, List<Bill>>> getAllBills() async {
    try {
      final bills = await localDatasource.getAllBills();
      return Right(bills);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Bill>>> getBillsByCustomer(String customerId) async {
    try {
      final bills = await localDatasource.getBillsByCustomer(customerId);
      return Right(bills);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Bill>> recordBill(Bill bill) async {
    try {
      final created = await localDatasource.recordBill(bill);
      return Right(created);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Bill>> updateBill(Bill bill) async {
    try {
      final updated = await localDatasource.updateBill(bill);
      return Right(updated);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateBillStatus(String billId, BillStatus status, double paidAmount) async {
    try {
      await localDatasource.updateBillStatus(billId, status, paidAmount);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteBill(String billId) async {
    try {
      await localDatasource.deleteBill(billId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
