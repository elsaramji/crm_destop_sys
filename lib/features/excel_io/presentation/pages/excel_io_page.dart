import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../activity/presentation/cubit/activity_cubit.dart';
import '../../../billing/presentation/cubit/billing_cubit.dart';
import '../../../customer/presentation/cubit/customer_list_cubit.dart';
import '../../../order/presentation/cubit/order_cubit.dart';
import '../../../service/presentation/cubit/service_cubit.dart';
import '../cubit/excel_io_cubit.dart';
import '../cubit/excel_io_state.dart';


class ExcelIoPage extends StatelessWidget {
  const ExcelIoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final customerCubit = context.read<CustomerListCubit>();
    final serviceCubit = context.read<ServiceCubit>();
    final activityCubit = context.read<ActivityCubit>();
    final orderCubit = context.read<OrderCubit>();
    final billingCubit = context.read<BillingCubit>();
    final excelCubit = context.read<ExcelIoCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Excel Data Portability Hub', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Multi-sheet spreadsheet export and import with National ID de-duplication rules', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row of Action Cards: Export on Left, Import on Right
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Export Card (P0-10)
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.download_for_offline, color: AppTheme.successGreen, size: 28),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Export Database to Excel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text('Generates .xlsx file with 5 dedicated sheets', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Sheets included in export:\n'
                            '• Customers (National ID, Name, Phones, Address)\n'
                            '• Services (Name, Category, Price, Date)\n'
                            '• Activities (Timeline events, notes)\n'
                            '• Orders (Ordered items, amounts, statuses)\n'
                            '• Bills (Amounts, paid, balance, due dates)',
                            style: TextStyle(fontSize: 12, color: AppTheme.textDark, height: 1.5),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successGreen),
                              icon: const Icon(Icons.file_download, size: 18),
                              label: const Text('Export .xlsx Now (P0-10)'),
                              onPressed: () {
                                excelCubit.exportAllData(
                                  customerCubit: customerCubit,
                                  serviceCubit: serviceCubit,
                                  activityCubit: activityCubit,
                                  orderCubit: orderCubit,
                                  billingCubit: billingCubit,
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Import Card (P0-11)
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFEFF6FF),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.upload_file, color: AppTheme.accentIndigo, size: 28),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Import from Excel', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text('Upload customer spreadsheets with duplicate checks', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Acceptance criteria verification (P0-11):\n'
                            '• Valid rows are parsed and added to registry\n'
                            '• Existing National IDs are flagged as duplicates\n'
                            '• Malformed rows (short IDs, invalid phones) are isolated\n'
                            '• Valid rows persist without being blocked',
                            style: TextStyle(fontSize: 12, color: AppTheme.textDark, height: 1.5),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryBlue),
                              icon: const Icon(Icons.file_upload, size: 18),
                              label: const Text('Simulate Excel Import (P0-11)'),
                              onPressed: () {
                                excelCubit.simulateImport(customerCubit: customerCubit);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Live Results / Reports Container
            BlocBuilder<ExcelIoCubit, ExcelIoState>(
              builder: (context, state) {
                if (state is ExcelIoProcessing) {
                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(36),
                      child: Center(
                        child: Column(
                          children: [
                            const CircularProgressIndicator(),
                            const SizedBox(height: 16),
                            Text(state.operationMessage, style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (state is ExcelExportSuccess) {
                  return Card(
                    color: const Color(0xFFF0FDF4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFBBF7D0)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 24),
                              const SizedBox(width: 12),
                              Text(
                                'Export Successful: ${state.filename}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF14532D)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              _Pill(label: 'Customers: ${state.customersCount}', bg: const Color(0xFFDCFCE7), fg: const Color(0xFF166534)),
                              _Pill(label: 'Services: ${state.servicesCount}', bg: const Color(0xFFEFF6FF), fg: const Color(0xFF1E40AF)),
                              _Pill(label: 'Activities: ${state.activitiesCount}', bg: const Color(0xFFFEF3C7), fg: const Color(0xFF92400E)),
                              _Pill(label: 'Orders: ${state.ordersCount}', bg: const Color(0xFFF3E8FF), fg: const Color(0xFF6B21A8)),
                              _Pill(label: 'Bills: ${state.billsCount}', bg: const Color(0xFFFEE2E2), fg: const Color(0xFF991B1B)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (state is ExcelImportSuccess) {
                  final report = state.report;

                  return Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Import Execution Summary (P0-11)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),

                          // Summary Pills
                          Wrap(
                            spacing: 12,
                            children: [
                              _Pill(label: 'Total Spreadsheet Rows: ${report.totalRows}', bg: const Color(0xFFF1F5F9), fg: Colors.black87),
                              _Pill(label: 'Valid Rows Imported: ${report.validRowsCount}', bg: const Color(0xFFDCFCE7), fg: const Color(0xFF166534)),
                              _Pill(label: 'Duplicate National IDs Flagged: ${report.duplicateNationalIds.length}', bg: const Color(0xFFFEF3C7), fg: const Color(0xFF92400E)),
                              _Pill(label: 'Malformed Rows Rejected: ${report.malformedRowErrors.length}', bg: const Color(0xFFFEE2E2), fg: const Color(0xFF991B1B)),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Duplicate Flag alert
                          if (report.duplicateNationalIds.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.warning_amber, color: Color(0xFFD97706), size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Duplicate Conflict Detected: ${report.duplicateNationalIds.join(", ")} was skipped or flagged to prevent record duplication.',
                                      style: const TextStyle(color: Color(0xFF92400E), fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],

                          // Malformed Row alert
                          if (report.malformedRowErrors.isNotEmpty) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFFECACA)),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.error_outline, color: AppTheme.dangerRed, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      report.malformedRowErrors.join("\n"),
                                      style: const TextStyle(color: Color(0xFF991B1B), fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Sample parsed rows table
                          const Text('Parsed Rows Inspector:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                          const SizedBox(height: 10),
                          DataTable(
                            headingRowColor: MaterialStateProperty.all(const Color(0xFFF1F5F9)),
                            columns: const [
                              DataColumn(label: Text('National ID')),
                              DataColumn(label: Text('Full Name')),
                              DataColumn(label: Text('Phone')),
                              DataColumn(label: Text('Parsed Status')),
                            ],
                            rows: report.importedSampleRows.map((r) {
                              final isError = r['Status']!.contains('Malformed');
                              final isDup = r['Status']!.contains('Duplicate');

                              return DataRow(
                                cells: [
                                  DataCell(Text(r['National ID']!)),
                                  DataCell(Text(r['Name']!)),
                                  DataCell(Text(r['Phone']!)),
                                  DataCell(
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isError
                                            ? const Color(0xFFFEE2E2)
                                            : (isDup ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7)),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        r['Status']!,
                                        style: TextStyle(
                                          color: isError
                                              ? const Color(0xFFB91C1C)
                                              : (isDup ? const Color(0xFFB45309) : const Color(0xFF15803D)),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const _Pill({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
