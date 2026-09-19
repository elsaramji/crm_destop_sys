import 'package:flutter_test/flutter_test.dart';
import 'package:crm_destop_sys/features/customer/presentation/cubit/customer_list_cubit.dart';
import 'package:crm_destop_sys/features/customer/presentation/cubit/customer_list_state.dart';
import 'package:crm_destop_sys/features/customer/domain/entities/customer.dart';

void main() {
  group('CustomerListCubit', () {
    late CustomerListCubit cubit;

    setUp(() {
      cubit = CustomerListCubit();
    });

    tearDown(() {
      cubit.close();
    });

    test('initial state is CustomerListLoaded with mock customers', () {
      expect(cubit.state, isA<CustomerListLoaded>());
      final loaded = cubit.state as CustomerListLoaded;
      expect(loaded.allCustomers.isNotEmpty, true);
    });

    test('getCustomerById returns customer when ID exists', () {
      final loaded = cubit.state as CustomerListLoaded;
      final expected = loaded.allCustomers.first;
      final result = cubit.getCustomerById(expected.id);
      expect(result, equals(expected));
    });

    test('getCustomerById returns null when ID does not exist', () {
      final result = cubit.getCustomerById('non_existing_id');
      expect(result, isNull);
    });

    test('getCustomerByIdOrNationalId matches by National ID exactly', () {
      final loaded = cubit.state as CustomerListLoaded;
      final expected = loaded.allCustomers.first;
      final result = cubit.getCustomerByIdOrNationalId(expected.nationalId);
      expect(result, equals(expected));
    });

    test('getCustomerByIdOrNationalId matches by Customer ID case-insensitively', () {
      final loaded = cubit.state as CustomerListLoaded;
      final expected = loaded.allCustomers.first;
      final result = cubit.getCustomerByIdOrNationalId(expected.id.toUpperCase());
      expect(result, equals(expected));
    });

    test('getCustomerByIdOrNationalId returns null for empty or non-matching query', () {
      expect(cubit.getCustomerByIdOrNationalId(''), isNull);
      expect(cubit.getCustomerByIdOrNationalId('   '), isNull);
      expect(cubit.getCustomerByIdOrNationalId('00000000000000'), isNull);
    });

    test('searchSuggestions returns matching customers by National ID, ID, or Name', () {
      final loaded = cubit.state as CustomerListLoaded;
      final firstCustomer = loaded.allCustomers.first;
      
      final byNationalId = cubit.searchSuggestions(firstCustomer.nationalId.substring(0, 4));
      expect(byNationalId.contains(firstCustomer), true);

      final byName = cubit.searchSuggestions(firstCustomer.fullName.substring(0, 3));
      expect(byName.contains(firstCustomer), true);
    });

    test('search filters customers properly', () {
      final loaded = cubit.state as CustomerListLoaded;
      final firstCustomer = loaded.allCustomers.first;
      
      cubit.search(firstCustomer.fullName);
      final searchLoaded = cubit.state as CustomerListLoaded;
      expect(searchLoaded.filteredCustomers.any((c) => c.id == firstCustomer.id), true);

      cubit.search('');
      final resetLoaded = cubit.state as CustomerListLoaded;
      expect(resetLoaded.filteredCustomers.length, equals(loaded.allCustomers.length));
    });
  });
}
