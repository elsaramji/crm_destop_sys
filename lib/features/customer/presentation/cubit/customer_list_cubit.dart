import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/customer.dart';
import '../../domain/usecases/create_customer.dart';
import '../../domain/usecases/delete_customer.dart';
import '../../domain/usecases/get_customers.dart';
import '../../domain/usecases/search_customers.dart';
import '../../domain/usecases/update_customer.dart';
import 'customer_list_state.dart';

class CustomerListCubit extends Cubit<CustomerListState> {
  final GetCustomers _getCustomers;
  final CreateCustomer _createCustomer;
  final UpdateCustomer _updateCustomer;
  final DeleteCustomer _deleteCustomer;
  final SearchCustomers _searchCustomers;

  CustomerListCubit({
    required GetCustomers getCustomers,
    required CreateCustomer createCustomer,
    required UpdateCustomer updateCustomer,
    required DeleteCustomer deleteCustomer,
    required SearchCustomers searchCustomers,
  })  : _getCustomers = getCustomers,
        _createCustomer = createCustomer,
        _updateCustomer = updateCustomer,
        _deleteCustomer = deleteCustomer,
        _searchCustomers = searchCustomers,
        super(const CustomerListLoading()) {
    loadCustomers();
  }

  Future<void> loadCustomers() async {
    emit(const CustomerListLoading());
    final result = await _getCustomers(const NoParams());
    result.fold(
      (failure) => emit(CustomerListError(failure.message)),
      (list) => emit(CustomerListLoaded(
        allCustomers: list,
        filteredCustomers: list,
      )),
    );
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
    emit(CustomerListLoaded(
      allCustomers: current.allCustomers,
      filteredCustomers: _applyFilters(current.allCustomers, current.searchQuery, branch),
      searchQuery: current.searchQuery,
      selectedBranch: branch,
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

  Future<bool> addCustomer(Customer customer) async {
    final result = await _createCustomer(customer);
    return result.fold(
      (failure) => false,
      (saved) {
        if (state is CustomerListLoaded) {
          final current = state as CustomerListLoaded;
          final updatedAll = [saved, ...current.allCustomers];
          emit(current.copyWith(
            allCustomers: updatedAll,
            filteredCustomers: _applyFilters(updatedAll, current.searchQuery, current.selectedBranch),
          ));
        } else {
          loadCustomers();
        }
        return true;
      },
    );
  }

  Future<bool> updateCustomer(Customer updated) async {
    final result = await _updateCustomer(updated);
    return result.fold(
      (failure) => false,
      (saved) {
        if (state is CustomerListLoaded) {
          final current = state as CustomerListLoaded;
          final updatedAll = current.allCustomers.map((c) => c.id == saved.id ? saved : c).toList();
          emit(current.copyWith(
            allCustomers: updatedAll,
            filteredCustomers: _applyFilters(updatedAll, current.searchQuery, current.selectedBranch),
          ));
        } else {
          loadCustomers();
        }
        return true;
      },
    );
  }

  Future<bool> deleteCustomer(String customerId) async {
    final result = await _deleteCustomer(customerId);
    return result.fold(
      (failure) => false,
      (_) {
        if (state is CustomerListLoaded) {
          final current = state as CustomerListLoaded;
          final updatedAll = current.allCustomers.where((c) => c.id != customerId).toList();
          emit(current.copyWith(
            allCustomers: updatedAll,
            filteredCustomers: _applyFilters(updatedAll, current.searchQuery, current.selectedBranch),
          ));
        }
        return true;
      },
    );
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

  Customer? getCustomerByIdOrNationalId(String query) {
    if (state is! CustomerListLoaded) return null;
    final current = state as CustomerListLoaded;
    final q = query.trim();
    if (q.isEmpty) return null;
    try {
      return current.allCustomers.firstWhere((c) =>
          c.nationalId.trim() == q ||
          c.id.trim().toLowerCase() == q.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  List<Customer> searchSuggestions(String query, {int limit = 5}) {
    if (state is! CustomerListLoaded) return [];
    final current = state as CustomerListLoaded;
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return [];
    return current.allCustomers
        .where((c) =>
            c.nationalId.toLowerCase().contains(q) ||
            c.id.toLowerCase().contains(q) ||
            c.fullName.toLowerCase().contains(q))
        .take(limit)
        .toList();
  }
}
