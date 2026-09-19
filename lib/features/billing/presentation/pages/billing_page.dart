import 'package:crm_destop_sys/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../customer/presentation/cubit/customer_list_cubit.dart';
import '../../domain/entities/bill.dart';
import '../cubit/billing_cubit.dart';
import '../cubit/billing_state.dart';
import '../widgets/bill_form_dialog.dart';
import '../widgets/ebill_preview_dialog.dart';

class BillingPage extends StatelessWidget {
  const BillingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Billing & Invoicing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Monitor revenue collection, receivables balance, and payment settlement',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add_card, size: 18),
            label: const Text('Record Invoice / Bill'),
            onPressed: () => BillFormDialog.show(context),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Balance Summary Bar
            BlocBuilder<BillingCubit, BillingState>(
              builder: (context, state) {
                final totalBilled = state is BillingLoaded
                    ? state.totalBilled
                    : 0.0;
                final totalCollected = state is BillingLoaded
                    ? state.totalCollected
                    : 0.0;
                final totalReceivables = state is BillingLoaded
                    ? state.totalReceivables
                    : 0.0;

                return Row(
                  children: [
                    _MetricBox(
                      title: 'Total Billed Revenue',
                      amount: 'EGP ${totalBilled.toStringAsFixed(2)}',
                      color: AppTheme.primaryBlue,
                      icon: Icons.account_balance_wallet_outlined,
                    ),
                    const SizedBox(width: 16),
                    _MetricBox(
                      title: 'Total Collected',
                      amount: 'EGP ${totalCollected.toStringAsFixed(2)}',
                      color: AppTheme.successGreen,
                      icon: Icons.check_circle_outline,
                    ),
                    const SizedBox(width: 16),
                    _MetricBox(
                      title: 'Outstanding Receivables',
                      amount: 'EGP ${totalReceivables.toStringAsFixed(2)}',
                      color: AppTheme.dangerRed,
                      icon: Icons.pending_actions_outlined,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Status Filter Bar
            BlocBuilder<BillingCubit, BillingState>(
              builder: (context, state) {
                final selected = state is BillingLoaded
                    ? state.statusFilter
                    : null;

                return Row(
                  children: [
                    const Text(
                      'Category / Status: ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ChoiceChip(
                      label: const Text('All'),
                      selected: selected == null,
                      onSelected: (_) =>
                          context.read<BillingCubit>().filterByStatus(null),
                    ),
                    const SizedBox(width: 8),
                    ...BillStatus.values.map((s) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(s.displayName),
                          selected: selected == s,
                          onSelected: (selectedBool) =>
                              context.read<BillingCubit>().filterByStatus(selectedBool ? s : null),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Billing Data Table
            Expanded(
              child: BlocBuilder<BillingCubit, BillingState>(
                builder: (context, state) {
                  if (state is! BillingLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final bills = state.filteredBills;

                  if (bills.isEmpty) {
                    return const Card(
                      child: Center(
                        child: Text(
                          'No bills matching filter.',
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
                                  'Invoice / Bill (E-Bill)',
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
                                  'Total (EGP)',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Paid (EGP)',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Remaining (EGP)',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataColumn(
                                label: Text(
                                  'Due Date',
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
                            rows: bills.map((b) {
                              final customer = context
                                  .read<CustomerListCubit>()
                                  .getCustomerById(b.customerId);

                              return DataRow(
                                cells: [
                                  // Invoice ID / Name - Hyperlink to E-Bill PDF Preview
                                  DataCell(
                                    InkWell(
                                      onTap: () => EBillPreviewDialog.show(
                                        context,
                                        bill: b,
                                        customer: customer,
                                      ),
                                      mouseCursor: SystemMouseCursors.click,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(Icons.picture_as_pdf_outlined, size: 18, color: Colors.redAccent),
                                          const SizedBox(width: 8),
                                          Column(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                b.description ?? 'Invoice',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color: AppTheme.primaryBlue,
                                                  decoration: TextDecoration.underline,
                                                  decorationColor: AppTheme.primaryBlue,
                                                ),
                                              ),
                                              Text(
                                                '#${b.id.length > 8 ? b.id.substring(b.id.length - 8) : b.id}',
                                                style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey,
                                                  fontFamily: 'monospace',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // Customer
                                  DataCell(
                                    InkWell(
                                      onTap: () {
                                        if (customer != null) {
                                          context.go('/customers/${customer.id}');
                                        }
                                      },
                                      mouseCursor: SystemMouseCursors.click,
                                      child: Text(
                                        customer?.fullName ?? b.customerId,
                                        style: const TextStyle(
                                          color: AppTheme.accentIndigo,
                                          fontWeight: FontWeight.w600,
                                          decoration: TextDecoration.underline,
                                          decorationColor: AppTheme.accentIndigo,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Total Amount
                                  DataCell(
                                    Text(
                                      'EGP ${b.amount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  // Paid Amount
                                  DataCell(
                                    Text(
                                      'EGP ${b.paidAmount.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        color: AppTheme.successGreen,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  // Remaining Amount
                                  DataCell(
                                    Text(
                                      'EGP ${b.remainingAmount.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: b.remainingAmount > 0
                                            ? AppTheme.dangerRed
                                            : Colors.grey,
                                      ),
                                    ),
                                  ),
                                  // Due Date
                                  DataCell(
                                    Text(
                                      '${b.dueDate.year}-${b.dueDate.month.toString().padLeft(2, '0')}-${b.dueDate.day.toString().padLeft(2, '0')}',
                                    ),
                                  ),
                                  // Status Badge
                                  DataCell(_buildStatusBadge(b.status)),
                                  // Actions Column
                                  DataCell(
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        // Preview E-Bill (PDF)
                                        IconButton(
                                          icon: const Icon(Icons.remove_red_eye_outlined, size: 18),
                                          tooltip: 'Preview & Print E-Bill (PDF)',
                                          color: AppTheme.primaryBlue,
                                          onPressed: () => EBillPreviewDialog.show(
                                            context,
                                            bill: b,
                                            customer: customer,
                                          ),
                                        ),
                                        // Edit Bill
                                        IconButton(
                                          icon: const Icon(Icons.edit_outlined, size: 18),
                                          tooltip: 'Edit Invoice',
                                          color: const Color(0xFF475569),
                                          onPressed: () => BillFormDialog.show(context, bill: b),
                                        ),
                                        // Delete Bill
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, size: 18),
                                          tooltip: 'Delete Invoice',
                                          color: AppTheme.dangerRed,
                                          onPressed: () => _confirmDeleteBill(context, b),
                                        ),
                                        const SizedBox(width: 4),
                                        // Mark Paid button (if unpaid/partial)
                                        if (b.status != BillStatus.paid)
                                          TextButton.icon(
                                            icon: const Icon(Icons.check, size: 14),
                                            label: const Text('Pay Full'),
                                            style: TextButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            onPressed: () {
                                              context.read<BillingCubit>().updateBillStatus(
                                                    b.id,
                                                    BillStatus.paid,
                                                    b.amount,
                                                  );
                                              ScaffoldMessenger.of(context).showSnackBar(
                                                const SnackBar(
                                                  content: Text('Bill marked as fully paid!'),
                                                ),
                                              );
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

  void _confirmDeleteBill(BuildContext context, Bill bill) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Invoice / Bill'),
        content: Text('Are you sure you want to delete invoice #${bill.id} (${bill.description ?? ""})? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            onPressed: () {
              context.read<BillingCubit>().deleteBill(bill.id);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Invoice #${bill.id} deleted.')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BillStatus status) {
    Color bg;
    Color fg;
    switch (status) {
      case BillStatus.paid:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
      case BillStatus.unpaid:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        break;
      case BillStatus.partial:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
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

class _MetricBox extends StatelessWidget {
  final String title;
  final String amount;
  final Color color;
  final IconData icon;

  const _MetricBox({
    required this.title,
    required this.amount,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      amount,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
