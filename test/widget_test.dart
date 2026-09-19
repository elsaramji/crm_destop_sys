import 'package:flutter_test/flutter_test.dart';
import 'package:crm_destop_sys/features/customer/domain/entities/customer.dart';

void main() {
  test('Customer entity equality and props test', () {
    final now = DateTime.now();
    final customer1 = Customer(
      id: '1',
      nationalId: '29501011234567',
      fullName: 'Ahmed Hassan',
      phoneNumbers: const ['01012345678'],
      createdAt: now,
      updatedAt: now,
    );

    final customer2 = Customer(
      id: '1',
      nationalId: '29501011234567',
      fullName: 'Ahmed Hassan',
      phoneNumbers: const ['01012345678'],
      createdAt: now,
      updatedAt: now,
    );

    expect(customer1, equals(customer2));
  });
}
