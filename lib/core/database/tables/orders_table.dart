import 'package:drift/drift.dart';
import 'customers_table.dart';

class OrdersTable extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text().references(CustomersTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get items => text()();
  TextColumn get status => text()();
  RealColumn get totalAmount => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
