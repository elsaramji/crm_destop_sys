import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/mock/mock_data.dart';
import '../../domain/entities/customer.dart';
import 'customer_list_state.dart';

class CustomerListCubit extends Cubit<CustomerListState> {
  CustomerListCubit() : super(const CustomerListLoading()) {
    loadCustomers();
  }

  void loadCustomers() {
    final list = List<Customer>.from(MockData.initialCustomers);
    emit(CustomerListLoaded(
      allCustomers: list,
      filteredCustomers: list,
    ));
  }

  void search(String query) {
    if (state is! CustomerListLoaded) return;
    final current = state as CustomerListLoaded;
    final q = query.trim().toLowerCase();

    if (q.isEmpty) {
      emit(current.copyWith(
        searchQuery: '',
        filteredCustomers: _applyFilters(current.allCustomers, '', current.selectedBranch),
      ));
      return;
    }

    final filtered = current.allCustomers.where((c) {
      final matchesName = c.fullName.toLowerCase().contains(q);
      final matchesNationalId = c.nationalId.contains(q);
      final matchesPhone = c.phoneNumbers.any((p) => p.contains(q));
      return matchesName || matchesNationalId || matchesPhone;
    }).toList();

    emit(current.copyWith(
      searchQuery: query,
      filteredCustomers: filtered,
    ));
  }

  void filterByBranch(String? branch) {
    if (state is! CustomerListLoaded) return;
    final current = state as CustomerListLoaded;
    emit(current.copyWith(
      selectedBranch: branch,
      filteredCustomers: _applyFilters(current.allCustomers, current.searchQuery, branch),
    ));
  }

  List<Customer> _applyFilters(List<Customer> all, String query, String? branch) {
    return all.where((c) {
      final q = query.trim().toLowerCase();
      final matchesQuery = q.isEmpty ||
          c.fullName.toLowerCase().contains(q) ||
          c.nationalId.contains(q) ||
          c.phoneNumbers.any((p) => p.contains(q));

      final matchesBranch = branch == null ||
          branch.isEmpty ||
          c.customFields['Preferred Branch'] == branch;

      return matchesQuery && matchesBranch;
    }).toList();
  }

  bool isNationalIdDuplicate(String nationalId, [String? excludeCustomerId]) {
    if (state is! CustomerListLoaded) return false;
    final current = state as CustomerListLoaded;
    return current.allCustomers.any((c) =>
        c.nationalId.trim() == nationalId.trim() &&
        (excludeCustomerId == null || c.id != excludeCustomerId));
  }

  void addCustomer(Customer customer) {
    if (state is! CustomerListLoaded) return;
    final current = state as CustomerListLoaded;

    final updatedAll = [customer, ...current.allCustomers];
    emit(current.copyWith(
      allCustomers: updatedAll,
      filteredCustomers: _applyFilters(updatedAll, current.searchQuery, current.selectedBranch),
    ));
  }

  void updateCustomer(Customer updated) {
    if (state is! CustomerListLoaded) return;
    final current = state as CustomerListLoaded;

    final updatedAll = current.allCustomers.map((c) => c.id == updated.id ? updated : c).toList();
    emit(current.copyWith(
      allCustomers: updatedAll,
      filteredCustomers: _applyFilters(updatedAll, current.searchQuery, current.selectedBranch),
    ));
  }

  void deleteCustomer(String customerId) {
    if (state is! CustomerListLoaded) return;
    final current = state as CustomerListLoaded;

    final updatedAll = current.allCustomers.where((c) => c.id != customerId).toList();
    emit(current.copyWith(
      allCustomers: updatedAll,
      filteredCustomers: _applyFilters(updatedAll, current.searchQuery, current.selectedBranch),
    ));
  }

  Customer? getCustomerById(String id) {
    if (state is! CustomerListLoaded) return null;
    final current = state as CustomerListLoaded;
    try {
      return current.allCustomers.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }
}
