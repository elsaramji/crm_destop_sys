import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../customer/presentation/cubit/customer_list_cubit.dart';
import '../../domain/entities/order.dart';
import '../cubit/order_cubit.dart';
import '../cubit/order_state.dart';
import '../widgets/order_form_dialog.dart';

class OrderListPage extends StatelessWidget {
  const OrderListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Orders Management',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Track client sales orders, fulfillment states, and delivery milestones',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add_shopping_cart, size: 18),
            label: const Text('Create Order'),
            onPressed: () => OrderFormDialog.show(context),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Filter Bar
            BlocBuilder<OrderCubit, OrderState>(
              builder: (context, state) {
                final selected = state is OrderLoaded
                    ? state.statusFilter
                    : null;

                return Row(
                  children: [
                    const Text(
                      'Status: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('All Orders'),
                      selected: selected == null,
                      onSelected: (_) =>
                          context.read<OrderCubit>().filterByStatus(null),
                    ),
                    const SizedBox(width: 8),
                    ...OrderStatus.values.map((s) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(s.displayName),
                          selected: selected == s,
                          onSelected: (_) =>
                              context.read<OrderCubit>().filterByStatus(s),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Orders Table
            Expanded(
              child: BlocBuilder<OrderCubit, OrderState>(
                builder: (context, state) {
                  if (state is! OrderLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final orders = state.filteredOrders;

                  if (orders.isEmpty) {
                    return const Card(
                      child: Center(
                        child: Text(
                          'No orders found matching status.',
                          style: TextStyle(color: AppTheme.textMuted),
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
                            headingRowColor: MaterialStateProperty.all(
                              const Color(0xFFF1F5F9),
                            ),
                            dataRowMaxHeight: 64,
                            columns: const [
                              DataColumn(
                                label: Text(
                                  'Order ID',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Customer',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Ordered Items',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Total (EGP)',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Order Date',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Status',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Actions',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                            rows: orders.map((o) {
                              final customer = context
                                  .read<CustomerListCubit>()
                                  .getCustomerById(o.customerId);

                              return DataRow(
                                cells: [
                                  // Order ID - Hyperlink to edit
                                  DataCell(
                                    InkWell(
                                      onTap: () => OrderFormDialog.show(context, order: o),
                                      mouseCursor: SystemMouseCursors.click,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.receipt_outlined, size: 16, color: AppTheme.primaryBlue),
                                          const SizedBox(width: 6),
                                          Text(
                                            '#${o.id.length > 8 ? o.id.substring(o.id.length - 8) : o.id}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'monospace',
                                              color: AppTheme.primaryBlue,
                                              decoration: TextDecoration.underline,
                                              decorationColor: AppTheme.primaryBlue,
                                            ),
                                          ),
                                          const SizedBox(width: 4),
                                          const Icon(Icons.edit_outlined, size: 12, color: AppTheme.textMuted),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Customer Account Hyperlink
                                  DataCell(
                                    InkWell(
                                      onTap: () {
                                        if (customer != null) {
                                          context.go('/customers/${customer.id}');
                                        }
                                      },
                                      mouseCursor: SystemMouseCursors.click,
                                      child: Text(
                                        customer?.fullName ?? o.customerId,
                                        style: const TextStyle(
                                          color: AppTheme.accentIndigo,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                          decorationColor: AppTheme.accentIndigo,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Ordered Items
                                  DataCell(
                                    ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 280,
                                      ),
                                      child: Text(
                                        o.items.join(', '),
                                        style: const TextStyle(fontSize: 13),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ),
                                  // Total Amount
                                  DataCell(
                                    Text(
                                      'EGP ${o.totalAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // Date
                                  DataCell(
                                    Text(
                                      '${o.createdAt.year}-${o.createdAt.month.toString().padLeft(2, '0')}-${o.createdAt.day.toString().padLeft(2, '0')}',
                                    ),
                                  ),
                                  // Status Dropdown
                                  DataCell(
                                    DropdownButtonHideUnderline(
                                      child: DropdownButton<OrderStatus>(
                                        value: o.status,
                                        items: OrderStatus.values.map((s) {
                                          return DropdownMenuItem(
                                            value: s,
                                            child: _buildStatusBadge(s),
                                          );
                                        }).toList(),
                                        onChanged: (newStatus) {
                                          if (newStatus != null) {
                                            context
                                                .read<OrderCubit>()
                                                .updateOrderStatus(
                                                  o.id,
                                                  newStatus,
                                                );
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                  // Actions Column
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18),
                                          tooltip: 'Edit Order',
                                          color: const Color(0xFF475569),
                                          onPressed: () => OrderFormDialog.show(context, order: o),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18),
                                          tooltip: 'Delete Order',
                                          color: AppTheme.dangerRed,
                                          onPressed: () => _confirmDelete(context, o),
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

  void _confirmDelete(BuildContext context, Order order) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Order'),
        content: Text('Are you sure you want to delete order #${order.id}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            onPressed: () {
              context.read<OrderCubit>().deleteOrder(order.id);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Order #${order.id} deleted.')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color bg;
    Color fg;
    switch (status) {
      case OrderStatus.pending:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        break;
      case OrderStatus.inProgress:
        bg = const Color(0xFFE0E7FF);
        fg = const Color(0xFF4338CA);
        break;
      case OrderStatus.completed:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
      case OrderStatus.cancelled:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.displayName,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
