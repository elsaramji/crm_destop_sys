import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/customer.dart';
import '../models/customer_model.dart';

abstract class CustomerLocalDatasource {
  Future<List<Customer>> getCustomers();
  Future<Customer> getCustomerById(String id);
  Future<Customer?> getCustomerByNationalId(String nationalId);
  Future<Customer> createCustomer(Customer customer);
  Future<Customer> updateCustomer(Customer customer);
  Future<void> deleteCustomer(String id);
  Future<List<Customer>> searchCustomers(String query);
}

class CustomerLocalDatasourceImpl implements CustomerLocalDatasource {
  final AppDatabase database;

  CustomerLocalDatasourceImpl(this.database);

  @override
  Future<List<Customer>> getCustomers() async {
    final rows = await (database.select(database.customersTable)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();

    final allPhones = await database.select(database.customerPhonesTable).get();
    final phonesByCustomerId = <String, List<String>>{};
    for (final p in allPhones) {
      phonesByCustomerId.putIfAbsent(p.customerId, () => []).add(p.phoneNumber);
    }

    return rows.map((r) {
      final phones = phonesByCustomerId[r.id] ?? [];
      return CustomerModel.fromDrift(r, phones);
    }).toList();
  }

  @override
  Future<Customer> getCustomerById(String id) async {
    final row = await (database.select(database.customersTable)
          ..where((t) => t.id.equals(id)))
        .getSingle();

    final phones = await (database.select(database.customerPhonesTable)
          ..where((t) => t.customerId.equals(id)))
        .get();

    return CustomerModel.fromDrift(row, phones.map((p) => p.phoneNumber).toList());
  }

  @override
  Future<Customer?> getCustomerByNationalId(String nationalId) async {
    final row = await (database.select(database.customersTable)
          ..where((t) => t.nationalId.equals(nationalId.trim())))
        .getSingleOrNull();

    if (row == null) return null;

    final phones = await (database.select(database.customerPhonesTable)
          ..where((t) => t.customerId.equals(row.id)))
        .get();

    return CustomerModel.fromDrift(row, phones.map((p) => p.phoneNumber).toList());
  }

  @override
  Future<Customer> createCustomer(Customer customer) async {
    return await database.transaction(() async {
      await database.into(database.customersTable).insert(CustomerModel.toCompanion(customer));

      for (final companion in CustomerModel.toPhoneCompanions(customer)) {
        await database.into(database.customerPhonesTable).insert(companion);
      }

      return customer;
    });
  }

  @override
  Future<Customer> updateCustomer(Customer customer) async {
    return await database.transaction(() async {
      await (database.update(database.customersTable)
            ..where((t) => t.id.equals(customer.id)))
          .write(CustomerModel.toCompanion(customer));

      await (database.delete(database.customerPhonesTable)
            ..where((t) => t.customerId.equals(customer.id)))
          .go();

      for (final companion in CustomerModel.toPhoneCompanions(customer)) {
        await database.into(database.customerPhonesTable).insert(companion);
      }

      return customer;
    });
  }

  @override
  Future<void> deleteCustomer(String id) async {
    await (database.delete(database.customersTable)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<List<Customer>> searchCustomers(String query) async {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return getCustomers();

    final all = await getCustomers();
    return all.where((c) {
      final matchesName = c.fullName.toLowerCase().contains(q);
      final matchesId = c.nationalId.contains(q);
      final matchesPhone = c.phoneNumbers.any((p) => p.contains(q));
      return matchesName || matchesId || matchesPhone;
    }).toList();
  }
}
