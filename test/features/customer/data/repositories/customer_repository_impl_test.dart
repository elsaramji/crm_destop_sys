import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crm_destop_sys/core/error/failures.dart';
import 'package:crm_destop_sys/features/customer/data/datasources/customer_local_datasource.dart';
import 'package:crm_destop_sys/features/customer/data/repositories/customer_repository_impl.dart';
import 'package:crm_destop_sys/features/customer/domain/entities/customer.dart';

class MockCustomerLocalDatasource extends Mock implements CustomerLocalDatasource {}

void main() {
  late CustomerRepositoryImpl repository;
  late MockCustomerLocalDatasource mockDatasource;

  setUp(() {
    mockDatasource = MockCustomerLocalDatasource();
    repository = CustomerRepositoryImpl(mockDatasource);
  });

  final testCustomer = Customer(
    id: 'cust_1',
    nationalId: '29501011234567',
    fullName: 'Ahmed Hassan',
    phoneNumbers: const ['01012345678'],
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  group('getCustomers', () {
    test('should return list of customers on success', () async {
      when(() => mockDatasource.getCustomers()).thenAnswer((_) async => [testCustomer]);

      final result = await repository.getCustomers();

      expect(result, Right([testCustomer]));
      verify(() => mockDatasource.getCustomers()).called(1);
    });

    test('should return DatabaseFailure on datasource exception', () async {
      when(() => mockDatasource.getCustomers()).thenThrow(Exception('DB error'));

      final result = await repository.getCustomers();

      expect(result.isLeft(), true);
      result.fold(
        (failure) => expect(failure, isA<DatabaseFailure>()),
        (_) => fail('should be failure'),
      );
    });
  });

  group('createCustomer', () {
    test('should return created customer when National ID is unique', () async {
      when(() => mockDatasource.getCustomerByNationalId(testCustomer.nationalId))
          .thenAnswer((_) async => null);
      when(() => mockDatasource.createCustomer(testCustomer))
          .thenAnswer((_) async => testCustomer);

      final result = await repository.createCustomer(testCustomer);

      expect(result, Right(testCustomer));
      verify(() => mockDatasource.createCustomer(testCustomer)).called(1);
    });

    test('should return DuplicateFailure when National ID already exists in DB', () async {
      when(() => mockDatasource.getCustomerByNationalId(testCustomer.nationalId))
          .thenAnswer((_) async => testCustomer);

      final result = await repository.createCustomer(testCustomer);

      expect(result, const Left(DuplicateFailure('A customer with this National ID already exists.')));
      verifyNever(() => mockDatasource.createCustomer(testCustomer));
    });
  });
}
