import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';
import 'package:crm_destop_sys/core/error/failures.dart';
import 'package:crm_destop_sys/core/usecase/usecase.dart';
import 'package:crm_destop_sys/features/customer/domain/entities/customer.dart';
import 'package:crm_destop_sys/features/customer/domain/usecases/create_customer.dart';
import 'package:crm_destop_sys/features/customer/domain/usecases/delete_customer.dart';
import 'package:crm_destop_sys/features/customer/domain/usecases/get_customers.dart';
import 'package:crm_destop_sys/features/customer/domain/usecases/search_customers.dart';
import 'package:crm_destop_sys/features/customer/domain/usecases/update_customer.dart';
import 'package:crm_destop_sys/features/customer/presentation/cubit/customer_list_cubit.dart';
import 'package:crm_destop_sys/features/customer/presentation/cubit/customer_list_state.dart';

class MockGetCustomers extends Mock implements GetCustomers {}
class MockCreateCustomer extends Mock implements CreateCustomer {}
class MockUpdateCustomer extends Mock implements UpdateCustomer {}
class MockDeleteCustomer extends Mock implements DeleteCustomer {}
class MockSearchCustomers extends Mock implements SearchCustomers {}

void main() {
  late MockGetCustomers mockGetCustomers;
  late MockCreateCustomer mockCreateCustomer;
  late MockUpdateCustomer mockUpdateCustomer;
  late MockDeleteCustomer mockDeleteCustomer;
  late MockSearchCustomers mockSearchCustomers;

  setUp(() {
    mockGetCustomers = MockGetCustomers();
    mockCreateCustomer = MockCreateCustomer();
    mockUpdateCustomer = MockUpdateCustomer();
    mockDeleteCustomer = MockDeleteCustomer();
    mockSearchCustomers = MockSearchCustomers();
  });

  final testCustomer = Customer(
    id: 'cust_1',
    nationalId: '29501011234567',
    fullName: 'Ahmed Hassan',
    phoneNumbers: const ['01012345678'],
    customFields: const {'Preferred Branch': 'Nasr City'},
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 1),
  );

  CustomerListCubit buildCubit() {
    return CustomerListCubit(
      getCustomers: mockGetCustomers,
      createCustomer: mockCreateCustomer,
      updateCustomer: mockUpdateCustomer,
      deleteCustomer: mockDeleteCustomer,
      searchCustomers: mockSearchCustomers,
    );
  }

  blocTest<CustomerListCubit, CustomerListState>(
    'emits [CustomerListLoading, CustomerListLoaded] when loadCustomers succeeds',
    build: () {
      when(() => mockGetCustomers(const NoParams()))
          .thenAnswer((_) async => Right([testCustomer]));
      return buildCubit();
    },
    expect: () => [
      const CustomerListLoading(),
      CustomerListLoaded(
        allCustomers: [testCustomer],
        filteredCustomers: [testCustomer],
      ),
    ],
  );

  blocTest<CustomerListCubit, CustomerListState>(
    'emits [CustomerListLoading, CustomerListError] when loadCustomers fails',
    build: () {
      when(() => mockGetCustomers(const NoParams()))
          .thenAnswer((_) async => const Left(DatabaseFailure('SQLite failed')));
      return buildCubit();
    },
    expect: () => [
      const CustomerListLoading(),
      const CustomerListError('SQLite failed'),
    ],
  );
}
