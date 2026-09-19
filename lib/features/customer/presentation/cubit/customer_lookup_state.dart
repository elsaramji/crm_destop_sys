import 'package:equatable/equatable.dart';
import '../../domain/entities/customer.dart';

class CustomerLookupState extends Equatable {
  final Customer? selectedCustomer;
  final String query;
  final List<Customer> suggestions;
  final bool hasSearched;

  const CustomerLookupState({
    this.selectedCustomer,
    this.query = '',
    this.suggestions = const [],
    this.hasSearched = false,
  });

  CustomerLookupState copyWith({
    Customer? Function()? selectedCustomer,
    String? query,
    List<Customer>? suggestions,
    bool? hasSearched,
  }) {
    return CustomerLookupState(
      selectedCustomer: selectedCustomer != null ? selectedCustomer() : this.selectedCustomer,
      query: query ?? this.query,
      suggestions: suggestions ?? this.suggestions,
      hasSearched: hasSearched ?? this.hasSearched,
    );
  }

  @override
  List<Object?> get props => [selectedCustomer, query, suggestions, hasSearched];
}
