import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer/presentation/cubit/customer_list_cubit.dart';
import '../../domain/entities/service_item.dart';
import '../cubit/service_cubit.dart';
import '../cubit/service_state.dart';
import '../widgets/service_form_dialog.dart';

class ServiceListPage extends StatelessWidget {
  const ServiceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Services Portfolio', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Global catalog of provided sales and services', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Service'),
            onPressed: () => ServiceFormDialog.show(context),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Filter Bar
            BlocBuilder<ServiceCubit, ServiceState>(
              builder: (context, state) {
                final selected = state is ServiceLoaded ? state.selectedCategory : null;
                const categories = ['All', 'Retail POS', 'Telecom', 'Maintenance', 'Software', 'Consulting'];

                return Row(
                  children: [
                    const Text('Category: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 8),
                    Wrap(
                      spacing: 8,
                      children: categories.map((cat) {
                        final isSelected = (cat == 'All' && selected == null) || (cat == selected);
                        return ChoiceChip(
                          label: Text(cat),
                          selected: isSelected,
                          onSelected: (_) {
                            context.read<ServiceCubit>().filterByCategory(cat == 'All' ? null : cat);
                          },
                        );
                      }).toList(),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Services Table
            Expanded(
              child: BlocBuilder<ServiceCubit, ServiceState>(
                builder: (context, state) {
                  if (state is! ServiceLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final services = state.filteredServices;

                  if (services.isEmpty) {
                    return const Card(
                      child: Center(
                        child: Text('No services found in this category.', style: TextStyle(color: AppTheme.textMuted)),
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
                            dataRowMaxHeight: 64,
                            columns: const [
                              DataColumn(label: Text('Service Name', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Customer Account', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Price', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Date Provided', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Notes', style: TextStyle(fontWeight: FontWeight.bold))),
                              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold))),
                            ],
                            rows: services.map((s) {
                              final customer = context.read<CustomerListCubit>().getCustomerById(s.customerId);

                              return DataRow(
                                cells: [
                                  // Service Name - Clickable Hyperlink
                                  DataCell(
                                    InkWell(
                                      onTap: () => ServiceFormDialog.show(context, service: s),
                                      mouseCursor: SystemMouseCursors.click,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.build_outlined, size: 16, color: AppTheme.primaryBlue),
                                          const SizedBox(width: 8),
                                          Text(
                                            s.name,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.primaryBlue,
                                              decoration: TextDecoration.underline,
                                              decorationColor: AppTheme.primaryBlue,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.edit_outlined, size: 13, color: AppTheme.textMuted),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Category
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(s.category, style: const TextStyle(color: Color(0xFF1E40AF), fontSize: 12)),
                                    ),
                                  ),
                                  // Customer Account
                                  DataCell(
                                    InkWell(
                                      onTap: () {
                                        if (customer != null) context.go('/customers/${customer.id}');
                                      },
                                      mouseCursor: SystemMouseCursors.click,
                                      child: Text(
                                        customer?.fullName ?? s.customerId,
                                        style: const TextStyle(
                                          color: AppTheme.accentIndigo,
                                          fontWeight: FontWeight.w500,
                                          decoration: TextDecoration.underline,
                                          decorationColor: AppTheme.accentIndigo,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Price
                                  DataCell(
                                    Text('EGP ${s.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                  ),
                                  // Date
                                  DataCell(
                                    Text('${s.dateProvided.year}-${s.dateProvided.month.toString().padLeft(2, '0')}-${s.dateProvided.day.toString().padLeft(2, '0')}'),
                                  ),
                                  // Notes
                                  DataCell(
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(maxWidth: 240),
                                      child: Text(
                                        s.notes ?? '—',
                                        style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  // Actions
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18),
                                          tooltip: 'Edit Service',
                                          color: const Color(0xFF475569),
                                          onPressed: () => ServiceFormDialog.show(context, service: s),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18),
                                          tooltip: 'Delete Service',
                                          color: AppTheme.dangerRed,
                                          onPressed: () => _confirmDelete(context, s),
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

  void _confirmDelete(BuildContext context, ServiceItem service) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service.name}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            onPressed: () {
              context.read<ServiceCubit>().deleteService(service.id);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Service "${service.name}" deleted.')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
