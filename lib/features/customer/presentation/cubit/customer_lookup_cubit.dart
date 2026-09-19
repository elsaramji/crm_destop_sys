import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/customer.dart';
import 'customer_list_cubit.dart';
import 'customer_lookup_state.dart';

class CustomerLookupCubit extends Cubit<CustomerLookupState> {
  final CustomerListCubit customerListCubit;

  CustomerLookupCubit(this.customerListCubit) : super(const CustomerLookupState());

  void init(String? initialCustomerId) {
    if (initialCustomerId == null || initialCustomerId.trim().isEmpty) return;
    final customer = customerListCubit.getCustomerById(initialCustomerId);
    if (customer != null) {
      emit(CustomerLookupState(
        selectedCustomer: customer,
        query: customer.nationalId,
        hasSearched: true,
      ));
    }
  }

  void searchById(String value) {
    final query = value.trim();
    if (query.isEmpty) {
      emit(const CustomerLookupState());
      return;
    }

    final matched = customerListCubit.getCustomerByIdOrNationalId(query);
    if (matched != null) {
      emit(CustomerLookupState(
        selectedCustomer: matched,
        query: value,
        suggestions: const [],
        hasSearched: true,
      ));
    } else {
      final suggestions = query.length >= 2
          ? customerListCubit.searchSuggestions(query)
          : const <Customer>[];
      emit(CustomerLookupState(
        selectedCustomer: null,
        query: value,
        suggestions: suggestions,
        hasSearched: true,
      ));
    }
  }

  void selectCustomer(Customer customer) {
    emit(CustomerLookupState(
      selectedCustomer: customer,
      query: customer.nationalId,
      suggestions: const [],
      hasSearched: true,
    ));
  }

  void clear() {
    emit(const CustomerLookupState());
  }
}
