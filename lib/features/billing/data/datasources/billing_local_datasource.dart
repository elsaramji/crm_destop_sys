import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/bill.dart';
import '../models/bill_model.dart';

abstract class BillingLocalDatasource {
  Future<List<Bill>> getAllBills();
  Future<List<Bill>> getBillsByCustomer(String customerId);
  Future<Bill> recordBill(Bill bill);
  Future<Bill> updateBill(Bill bill);
  Future<void> updateBillStatus(String billId, BillStatus status, double paidAmount);
  Future<void> deleteBill(String billId);
}

class BillingLocalDatasourceImpl implements BillingLocalDatasource {
  final AppDatabase database;

  BillingLocalDatasourceImpl(this.database);

  @override
  Future<List<Bill>> getAllBills() async {
    final rows = await (database.select(database.billsTable)
          ..orderBy([(t) => OrderingTerm.desc(t.issuedAt)]))
        .get();
    return rows.map(BillModel.fromDrift).toList();
  }

  @override
  Future<List<Bill>> getBillsByCustomer(String customerId) async {
    final rows = await (database.select(database.billsTable)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm.desc(t.issuedAt)]))
        .get();
    return rows.map(BillModel.fromDrift).toList();
  }

  @override
  Future<Bill> recordBill(Bill bill) async {
    await database.into(database.billsTable).insert(BillModel.toCompanion(bill));
    return bill;
  }

  @override
  Future<Bill> updateBill(Bill bill) async {
    await (database.update(database.billsTable)
          ..where((t) => t.id.equals(bill.id)))
        .write(BillModel.toCompanion(bill));
    return bill;
  }

  @override
  Future<void> updateBillStatus(String billId, BillStatus status, double paidAmount) async {
    await (database.update(database.billsTable)..where((t) => t.id.equals(billId))).write(
      BillsTableCompanion(
        status: Value(status.name),
        paidAmount: Value(paidAmount),
      ),
    );
  }

  @override
  Future<void> deleteBill(String billId) async {
    await (database.delete(database.billsTable)..where((t) => t.id.equals(billId))).go();
  }
}
