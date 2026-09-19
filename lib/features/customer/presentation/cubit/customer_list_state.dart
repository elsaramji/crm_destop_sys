import 'package:equatable/equatable.dart';
import '../../domain/entities/customer.dart';

abstract class CustomerListState extends Equatable {
  const CustomerListState();

  @override
  List<Object?> get props => [];
}

class CustomerListLoading extends CustomerListState {
  const CustomerListLoading();
}

class CustomerListLoaded extends CustomerListState {
  final List<Customer> allCustomers;
  final List<Customer> filteredCustomers;
  final String searchQuery;
  final String? selectedBranch;

  const CustomerListLoaded({
    required this.allCustomers,
    required this.filteredCustomers,
    this.searchQuery = '',
    this.selectedBranch,
  });

  CustomerListLoaded copyWith({
    List<Customer>? allCustomers,
    List<Customer>? filteredCustomers,
    String? searchQuery,
    String? selectedBranch,
  }) {
    return CustomerListLoaded(
      allCustomers: allCustomers ?? this.allCustomers,
      filteredCustomers: filteredCustomers ?? this.filteredCustomers,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedBranch: selectedBranch ?? this.selectedBranch,
    );
  }

  @override
  List<Object?> get props => [
        allCustomers,
        filteredCustomers,
        searchQuery,
        selectedBranch,
      ];
}

class CustomerListError extends CustomerListState {
  final String message;
  const CustomerListError(this.message);

  @override
  List<Object?> get props => [message];
}
