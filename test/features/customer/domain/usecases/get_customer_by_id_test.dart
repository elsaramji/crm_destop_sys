import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crm_destop_sys/core/error/failures.dart';
import 'package:crm_destop_sys/features/customer/domain/entities/customer.dart';
import 'package:crm_destop_sys/features/customer/domain/repositories/customer_repository.dart';
import 'package:crm_destop_sys/features/customer/domain/usecases/get_customer_by_id.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

void main() {
  late GetCustomerById useCase;
  late MockCustomerRepository mockRepository;

  setUp(() {
    mockRepository = MockCustomerRepository();
    useCase = GetCustomerById(mockRepository);
  });

  const testId = 'cust_1';
  final testCustomer = Customer(
    id: testId,
    nationalId: '29501011234567',
    fullName: 'Test Ahmed',
    phoneNumbers: const ['01012345678'],
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  test('should return Customer when found by ID', () async {
    when(() => mockRepository.getCustomerById(testId))
        .thenAnswer((_) async => Right(testCustomer));

    final result = await useCase(testId);

    expect(result, Right(testCustomer));
    verify(() => mockRepository.getCustomerById(testId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return NotFoundFailure when customer does not exist', () async {
    const failure = NotFoundFailure('Requested resource not found');
    when(() => mockRepository.getCustomerById(testId))
        .thenAnswer((_) async => const Left(failure));

    final result = await useCase(testId);

    expect(result, const Left(failure));
    verify(() => mockRepository.getCustomerById(testId)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
