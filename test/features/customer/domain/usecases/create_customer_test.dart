import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crm_destop_sys/core/error/failures.dart';
import 'package:crm_destop_sys/features/customer/domain/entities/customer.dart';
import 'package:crm_destop_sys/features/customer/domain/repositories/customer_repository.dart';
import 'package:crm_destop_sys/features/customer/domain/usecases/create_customer.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

void main() {
  late CreateCustomer useCase;
  late MockCustomerRepository mockRepository;

  setUp(() {
    mockRepository = MockCustomerRepository();
    useCase = CreateCustomer(mockRepository);
  });

  final testCustomer = Customer(
    id: 'test_1',
    nationalId: '29501011234567',
    fullName: 'Test Ahmed',
    phoneNumbers: const ['01012345678'],
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  test('should return created Customer from the repository on success', () async {
    when(() => mockRepository.createCustomer(testCustomer))
        .thenAnswer((_) async => Right(testCustomer));

    final result = await useCase(testCustomer);

    expect(result, Right(testCustomer));
    verify(() => mockRepository.createCustomer(testCustomer)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return DuplicateFailure when National ID already exists', () async {
    const failure = DuplicateFailure('Record already exists');
    when(() => mockRepository.createCustomer(testCustomer))
        .thenAnswer((_) async => const Left(failure));

    final result = await useCase(testCustomer);

    expect(result, const Left(failure));
    verify(() => mockRepository.createCustomer(testCustomer)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
