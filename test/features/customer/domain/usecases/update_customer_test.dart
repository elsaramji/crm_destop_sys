import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crm_destop_sys/core/error/failures.dart';
import 'package:crm_destop_sys/features/customer/domain/entities/customer.dart';
import 'package:crm_destop_sys/features/customer/domain/repositories/customer_repository.dart';
import 'package:crm_destop_sys/features/customer/domain/usecases/update_customer.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

void main() {
  late UpdateCustomer useCase;
  late MockCustomerRepository mockRepository;

  setUp(() {
    mockRepository = MockCustomerRepository();
    useCase = UpdateCustomer(mockRepository);
  });

  final testCustomer = Customer(
    id: 'cust_1',
    nationalId: '29501011234567',
    fullName: 'Ahmed Mahmoud Hassan Updated',
    phoneNumbers: const ['01012345678'],
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 2),
  );

  test('should return updated Customer from repository on success', () async {
    when(() => mockRepository.updateCustomer(testCustomer))
        .thenAnswer((_) async => Right(testCustomer));

    final result = await useCase(testCustomer);

    expect(result, Right(testCustomer));
    verify(() => mockRepository.updateCustomer(testCustomer)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return DatabaseFailure on failure', () async {
    const failure = DatabaseFailure('Update failed');
    when(() => mockRepository.updateCustomer(testCustomer))
        .thenAnswer((_) async => const Left(failure));

    final result = await useCase(testCustomer);

    expect(result, const Left(failure));
    verify(() => mockRepository.updateCustomer(testCustomer)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
