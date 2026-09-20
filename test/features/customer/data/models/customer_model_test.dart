import 'package:flutter_test/flutter_test.dart';
import 'package:crm_destop_sys/core/database/app_database.dart';
import 'package:crm_destop_sys/features/customer/data/models/customer_model.dart';
import 'package:crm_destop_sys/features/customer/domain/entities/customer.dart';

void main() {
  final testDate = DateTime(2026, 1, 1);
  final testRow = CustomersTableData(
    id: 'cust_1',
    nationalId: '29501011234567',
    fullName: 'Ahmed Hassan',
    address: 'Cairo, Egypt',
    email: 'ahmed@example.com',
    customFields: '{"Preferred Branch":"Nasr City"}',
    createdAt: testDate,
    updatedAt: testDate,
  );

  test('fromDrift should correctly map CustomersTableData to Customer entity', () {
    final customer = CustomerModel.fromDrift(testRow, ['01012345678', '01123456789']);

    expect(customer.id, 'cust_1');
    expect(customer.nationalId, '29501011234567');
    expect(customer.fullName, 'Ahmed Hassan');
    expect(customer.address, 'Cairo, Egypt');
    expect(customer.email, 'ahmed@example.com');
    expect(customer.phoneNumbers, ['01012345678', '01123456789']);
    expect(customer.customFields['Preferred Branch'], 'Nasr City');
    expect(customer.createdAt, testDate);
    expect(customer.updatedAt, testDate);
  });

  test('toCompanion should correctly convert Customer entity to CustomersTableCompanion', () {
    final customer = Customer(
      id: 'cust_1',
      nationalId: '29501011234567',
      fullName: 'Ahmed Hassan',
      phoneNumbers: const ['01012345678'],
      address: 'Cairo, Egypt',
      email: 'ahmed@example.com',
      customFields: const {'VIP Tier': 'Gold'},
      createdAt: testDate,
      updatedAt: testDate,
    );

    final companion = CustomerModel.toCompanion(customer);

    expect(companion.id.value, 'cust_1');
    expect(companion.nationalId.value, '29501011234567');
    expect(companion.fullName.value, 'Ahmed Hassan');
    expect(companion.address.value, 'Cairo, Egypt');
    expect(companion.email.value, 'ahmed@example.com');
    expect(companion.customFields.value, '{"VIP Tier":"Gold"}');
  });
}
