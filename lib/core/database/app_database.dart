import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'tables/customers_table.dart';
import 'tables/customer_phones_table.dart';
import 'tables/services_table.dart';
import 'tables/activities_table.dart';
import 'tables/orders_table.dart';
import 'tables/bills_table.dart';
import 'tables/admins_table.dart';
import '../mock/mock_data.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  CustomersTable,
  CustomerPhonesTable,
  ServicesTable,
  ActivitiesTable,
  OrdersTable,
  BillsTable,
  AdminsTable,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? e]) : super(e ?? _openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'crm_desktop_db');
  }

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        await _seedInitialData();
      },
    );
  }

  Future<void> seedIfEmpty() async {
    final existingCustomers = await (select(customersTable)..limit(1)).get();
    if (existingCustomers.isEmpty) {
      await _seedInitialData();
    }
  }

  Future<void> _seedInitialData() async {
    // 1. Seed Admin
    await into(adminsTable).insertOnConflictUpdate(
      AdminsTableCompanion.insert(
        id: MockData.defaultAdmin.id,
        username: MockData.defaultAdmin.username,
        name: MockData.defaultAdmin.name,
        email: MockData.defaultAdmin.email,
        passwordHash: 'admin123',
      ),
    );

    // 2. Seed Customers & Customer Phones
    for (final c in MockData.initialCustomers) {
      await into(customersTable).insertOnConflictUpdate(
        CustomersTableCompanion.insert(
          id: c.id,
          nationalId: c.nationalId,
          fullName: c.fullName,
          address: Value(c.address),
          email: Value(c.email),
          customFields: Value(jsonEncode(c.customFields)),
          createdAt: c.createdAt,
          updatedAt: c.updatedAt,
        ),
      );

      for (final phone in c.phoneNumbers) {
        await into(customerPhonesTable).insert(
          CustomerPhonesTableCompanion.insert(
            customerId: c.id,
            phoneNumber: phone,
          ),
        );
      }
    }

    // 3. Seed Services
    for (final s in MockData.initialServices) {
      await into(servicesTable).insertOnConflictUpdate(
        ServicesTableCompanion.insert(
          id: s.id,
          customerId: s.customerId,
          name: s.name,
          category: s.category,
          price: s.price,
          dateProvided: s.dateProvided,
          notes: Value(s.notes),
        ),
      );
    }

    // 4. Seed Activities
    for (final a in MockData.initialActivities) {
      await into(activitiesTable).insertOnConflictUpdate(
        ActivitiesTableCompanion.insert(
          id: a.id,
          customerId: a.customerId,
          type: a.type.name,
          note: a.note,
          timestamp: a.timestamp,
        ),
      );
    }

    // 5. Seed Orders
    for (final o in MockData.initialOrders) {
      await into(ordersTable).insertOnConflictUpdate(
        OrdersTableCompanion.insert(
          id: o.id,
          customerId: o.customerId,
          items: jsonEncode(o.items),
          status: o.status.name,
          totalAmount: o.totalAmount,
          createdAt: o.createdAt,
          updatedAt: o.updatedAt,
        ),
      );
    }

    // 6. Seed Bills
    for (final b in MockData.initialBills) {
      await into(billsTable).insertOnConflictUpdate(
        BillsTableCompanion.insert(
          id: b.id,
          customerId: b.customerId,
          amount: b.amount,
          paidAmount: Value(b.paidAmount),
          status: b.status.name,
          dueDate: b.dueDate,
          issuedAt: b.issuedAt,
          description: Value(b.description),
        ),
      );
    }
  }
}
