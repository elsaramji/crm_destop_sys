import 'dart:convert';
import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/customer.dart';

class CustomerModel {
  static Customer fromDrift(CustomersTableData row, List<String> phoneNumbers) {
    Map<String, String> customFieldsMap = {};
    try {
      final decoded = jsonDecode(row.customFields);
      if (decoded is Map) {
        customFieldsMap = decoded.map((k, v) => MapEntry(k.toString(), v.toString()));
      }
    } catch (_) {}

    return Customer(
      id: row.id,
      nationalId: row.nationalId,
      fullName: row.fullName,
      phoneNumbers: phoneNumbers,
      address: row.address,
      email: row.email,
      customFields: customFieldsMap,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  static CustomersTableCompanion toCompanion(Customer customer) {
    return CustomersTableCompanion.insert(
      id: customer.id,
      nationalId: customer.nationalId,
      fullName: customer.fullName,
      address: Value(customer.address),
      email: Value(customer.email),
      customFields: Value(jsonEncode(customer.customFields)),
      createdAt: customer.createdAt,
      updatedAt: customer.updatedAt,
    );
  }

  static List<CustomerPhonesTableCompanion> toPhoneCompanions(Customer customer) {
    return customer.phoneNumbers
        .where((p) => p.trim().isNotEmpty)
        .map((p) => CustomerPhonesTableCompanion.insert(
              customerId: customer.id,
              phoneNumber: p.trim(),
            ))
        .toList();
  }
}
