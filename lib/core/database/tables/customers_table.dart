import 'package:drift/drift.dart';

class CustomersTable extends Table {
  TextColumn get id => text()();
  TextColumn get nationalId => text().unique()();
  TextColumn get fullName => text()();
  TextColumn get address => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get customFields => text().withDefault(const Constant('{}'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}
