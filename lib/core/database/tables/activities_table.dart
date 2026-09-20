import 'package:drift/drift.dart';
import 'customers_table.dart';

class ActivitiesTable extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text().references(CustomersTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get type => text()();
  TextColumn get note => text()();
  DateTimeColumn get timestamp => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
