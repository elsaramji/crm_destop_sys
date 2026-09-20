import 'package:drift/drift.dart';
import 'customers_table.dart';

class BillsTable extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text().references(CustomersTable, #id, onDelete: KeyAction.cascade)();
  RealColumn get amount => real()();
  RealColumn get paidAmount => real().withDefault(const Constant(0.0))();
  TextColumn get status => text()();
  DateTimeColumn get dueDate => dateTime()();
  DateTimeColumn get issuedAt => dateTime()();
  TextColumn get description => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
