import 'package:drift/drift.dart';

class AdminsTable extends Table {
  TextColumn get id => text()();
  TextColumn get username => text().unique()();
  TextColumn get name => text()();
  TextColumn get email => text()();
  TextColumn get passwordHash => text()();
  DateTimeColumn get lastLoginAt => dateTime().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}
