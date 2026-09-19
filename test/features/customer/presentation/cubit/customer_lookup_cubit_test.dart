import 'package:flutter_test/flutter_test.dart';
import 'package:crm_destop_sys/features/customer/presentation/cubit/customer_list_cubit.dart';
import 'package:crm_destop_sys/features/customer/presentation/cubit/customer_lookup_cubit.dart';
import 'package:crm_destop_sys/features/customer/presentation/cubit/customer_lookup_state.dart';
import 'package:crm_destop_sys/features/customer/presentation/cubit/customer_list_state.dart';

void main() {
  group('CustomerLookupCubit', () {
    late CustomerListCubit customerListCubit;
    late CustomerLookupCubit lookupCubit;

    setUp(() {
      customerListCubit = CustomerListCubit();
      lookupCubit = CustomerLookupCubit(customerListCubit);
    });

    tearDown(() {
      lookupCubit.close();
      customerListCubit.close();
    });

    test('initial state has no selected customer', () {
      expect(lookupCubit.state, equals(const CustomerLookupState()));
      expect(lookupCubit.state.selectedCustomer, isNull);
      expect(lookupCubit.state.hasSearched, isFalse);
    });

    test('init loads existing customer by ID', () {
      final loaded = customerListCubit.state as CustomerListLoaded;
      final target = loaded.allCustomers.first;

      lookupCubit.init(target.id);

      expect(lookupCubit.state.selectedCustomer, equals(target));
      expect(lookupCubit.state.query, equals(target.nationalId));
      expect(lookupCubit.state.hasSearched, isTrue);
    });

    test('init does nothing if ID is null or empty', () {
      lookupCubit.init(null);
      expect(lookupCubit.state, equals(const CustomerLookupState()));

      lookupCubit.init('   ');
      expect(lookupCubit.state, equals(const CustomerLookupState()));
    });

    test('searchById finds customer by exact National ID', () {
      final loaded = customerListCubit.state as CustomerListLoaded;
      final target = loaded.allCustomers.first;

      lookupCubit.searchById(target.nationalId);

      expect(lookupCubit.state.selectedCustomer, equals(target));
      expect(lookupCubit.state.hasSearched, isTrue);
      expect(lookupCubit.state.suggestions, isEmpty);
    });

    test('searchById finds customer by exact Customer ID', () {
      final loaded = customerListCubit.state as CustomerListLoaded;
      final target = loaded.allCustomers.first;

      lookupCubit.searchById(target.id);

      expect(lookupCubit.state.selectedCustomer, equals(target));
      expect(lookupCubit.state.hasSearched, isTrue);
    });

    test('searchById provides suggestions when not exact match', () {
      final loaded = customerListCubit.state as CustomerListLoaded;
      final target = loaded.allCustomers.first;
      final partialQuery = target.nationalId.substring(0, 4);

      lookupCubit.searchById(partialQuery);

      expect(lookupCubit.state.selectedCustomer, isNull);
      expect(lookupCubit.state.hasSearched, isTrue);
      expect(lookupCubit.state.suggestions.contains(target), isTrue);
    });

    test('searchById resets state on empty query', () {
      final loaded = customerListCubit.state as CustomerListLoaded;
      final target = loaded.allCustomers.first;
      lookupCubit.searchById(target.nationalId);

      lookupCubit.searchById('');
      expect(lookupCubit.state, equals(const CustomerLookupState()));
    });

    test('selectCustomer sets customer and updates query', () {
      final loaded = customerListCubit.state as CustomerListLoaded;
      final target = loaded.allCustomers.first;

      lookupCubit.selectCustomer(target);

      expect(lookupCubit.state.selectedCustomer, equals(target));
      expect(lookupCubit.state.query, equals(target.nationalId));
      expect(lookupCubit.state.suggestions, isEmpty);
      expect(lookupCubit.state.hasSearched, isTrue);
    });

    test('clear resets state', () {
      final loaded = customerListCubit.state as CustomerListLoaded;
      final target = loaded.allCustomers.first;
      lookupCubit.selectCustomer(target);

      lookupCubit.clear();
      expect(lookupCubit.state, equals(const CustomerLookupState()));
    });
  });
}
