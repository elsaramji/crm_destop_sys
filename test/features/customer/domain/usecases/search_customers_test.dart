import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crm_destop_sys/core/error/failures.dart';
import 'package:crm_destop_sys/features/customer/domain/entities/customer.dart';
import 'package:crm_destop_sys/features/customer/domain/repositories/customer_repository.dart';
import 'package:crm_destop_sys/features/customer/domain/usecases/search_customers.dart';

class MockCustomerRepository extends Mock implements CustomerRepository {}

void main() {
  late SearchCustomers useCase;
  late MockCustomerRepository mockRepository;

  setUp(() {
    mockRepository = MockCustomerRepository();
    useCase = SearchCustomers(mockRepository);
  });

  const query = 'Ahmed';
  final testList = [
    Customer(
      id: 'cust_1',
      nationalId: '29501011234567',
      fullName: 'Ahmed Mahmoud Hassan',
      phoneNumbers: const ['01012345678'],
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    ),
  ];

  test('should return list of matched customers on search', () async {
    when(() => mockRepository.searchCustomers(query))
        .thenAnswer((_) async => Right(testList));

    final result = await useCase(query);

    expect(result, Right(testList));
    verify(() => mockRepository.searchCustomers(query)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return DatabaseFailure on repository failure', () async {
    const failure = DatabaseFailure('Database operation failed');
    when(() => mockRepository.searchCustomers(query))
        .thenAnswer((_) async => const Left(failure));

    final result = await useCase(query);

    expect(result, const Left(failure));
    verify(() => mockRepository.searchCustomers(query)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
