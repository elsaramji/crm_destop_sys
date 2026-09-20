import 'package:drift/drift.dart';
import 'customers_table.dart';

class ServicesTable extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text().references(CustomersTable, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  TextColumn get category => text()();
  RealColumn get price => real()();
  DateTimeColumn get dateProvided => dateTime()();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
