import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/bill.dart';

class BillModel {
  static Bill fromDrift(BillsTableData row) {
    return Bill(
      id: row.id,
      customerId: row.customerId,
      amount: row.amount,
      paidAmount: row.paidAmount,
      status: BillStatus.fromString(row.status),
      dueDate: row.dueDate,
      issuedAt: row.issuedAt,
      description: row.description,
    );
  }

  static BillsTableCompanion toCompanion(Bill bill) {
    return BillsTableCompanion.insert(
      id: bill.id,
      customerId: bill.customerId,
      amount: bill.amount,
      paidAmount: Value(bill.paidAmount),
      status: bill.status.name,
      dueDate: bill.dueDate,
      issuedAt: bill.issuedAt,
      description: Value(bill.description),
    );
  }
}
