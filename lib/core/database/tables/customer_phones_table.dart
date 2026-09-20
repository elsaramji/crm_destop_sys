import 'package:drift/drift.dart';
import 'customers_table.dart';

class CustomerPhonesTable extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get customerId => text().references(CustomersTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get phoneNumber => text()();
}
