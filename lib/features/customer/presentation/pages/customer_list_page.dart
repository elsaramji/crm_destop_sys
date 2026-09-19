import 'package:crm_destop_sys/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/customer_list_cubit.dart';
import '../cubit/customer_list_state.dart';
import '../widgets/customer_search_bar.dart';

class CustomerListPage extends StatelessWidget {
  const CustomerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Customer Accounts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Central registry with National ID de-duplication', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Customer'),
            onPressed: () => context.go('/customers/new'),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const CustomerSearchBar(),
            const SizedBox(height: 20),
            Expanded(
              child: BlocBuilder<CustomerListCubit, CustomerListState>(
                builder: (context, state) {
                  if (state is CustomerListLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is! CustomerListLoaded) {
                    return const Center(child: Text('Failed to load customers'));
                  }

                  final customers = state.filteredCustomers;

                  if (customers.isEmpty) {
                    return Card(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.search_off, size: 48, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text(
                              state.searchQuery.isNotEmpty
                                  ? 'No customers found matching "${state.searchQuery}"'
                                  : 'No customer records yet.',
                              style: const TextStyle(fontSize: 15, color: AppTheme.textMuted),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Card(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
                            dataRowMaxHeight: 68,
                            columns: const [
                              DataColumn(label: Text('Customer Name', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('National ID', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Phone Numbers', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Address', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Tags / Branch', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: customers.map((c) {
                              return DataRow(
                                cells: [
                                  // Name
                                  DataCell(
                                    InkWell(
                                      onTap: () => context.go('/customers/${c.id}'),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircleAvatar(
                                            radius: 16,
                                            backgroundColor: const Color(0xFFEEF2FF),
                                            child: Text(
                                              c.fullName.isNotEmpty ? c.fullName[0].toUpperCase() : 'C',
                                              style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 13),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Text(
                                            c.fullName,
                                            style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF1E3A8A)),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // National ID
                                  DataCell(
                                    SelectableText(
                                      c.nationalId,
                                      style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  // Phone numbers
                                  DataCell(
                                    Wrap(
                                      spacing: 6,
                                      runSpacing: 4,
                                      children: c.phoneNumbers.map((phone) {
                                        return Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(6),
                                            border: Border.all(color: const Color(0xFFCBD5E1)),
                                          ),
                                          child: Text(phone, style: const TextStyle(fontSize: 12)),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                  // Address
                                  DataCell(
                                    Text(
                                      c.address ?? '—',
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ),
                                  // Tags / Branch
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (c.customFields.containsKey('Preferred Branch'))
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            margin: const EdgeInsets.only(right: 6),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFE0F2FE),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              c.customFields['Preferred Branch']!,
                                              style: const TextStyle(color: Color(0xFF0369A1), fontSize: 11, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                        if (c.customFields.containsKey('VIP Tier'))
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFEF3C7),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              c.customFields['VIP Tier']!,
                                              style: const TextStyle(color: Color(0xFFB45309), fontSize: 11, fontWeight: FontWeight.w600),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                  // Actions
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.visibility_outlined, size: 18),
                                          tooltip: 'View Profile',
                                          color: AppTheme.primaryBlue,
                                          onPressed: () => context.go('/customers/${c.id}'),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18),
                                          tooltip: 'Edit Record',
                                          color: const Color(0xFF475569),
                                          onPressed: () => context.go('/customers/${c.id}/edit'),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18),
                                          tooltip: 'Delete',
                                          color: AppTheme.dangerRed,
                                          onPressed: () {
                                            _confirmDelete(context, c.id, c.fullName);
                                          },
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, String customerId, String name) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text('Are you sure you want to delete the record for "$name"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            onPressed: () {
              context.read<CustomerListCubit>().deleteCustomer(customerId);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Customer "$name" deleted')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
