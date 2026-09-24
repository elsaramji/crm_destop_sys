import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/desktop_file_launcher.dart';
import '../../../../core/utils/desktop_file_picker.dart';
import '../../../customer/presentation/cubit/customer_list_cubit.dart';
import '../../domain/entities/duplicate_strategy.dart';
import '../../domain/entities/excel_parsed_row.dart';
import '../cubit/excel_io_cubit.dart';
import '../cubit/excel_io_state.dart';
import '../widgets/excel_import_dialog.dart';

class ExcelIoPage extends StatelessWidget {
  const ExcelIoPage({super.key});

  @override
  Widget build(BuildContext context) {
    final customerCubit = context.read<CustomerListCubit>();
    final excelCubit = context.read<ExcelIoCubit>();

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Excel Data Portability Hub',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(
              'Multi-sheet spreadsheet export & real import with National ID de-duplication rules',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
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
                                child: const Icon(Icons.download_for_offline,
                                    color: AppTheme.successGreen, size: 28),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Export Database to Excel',
                                        style: TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text('Generates real .xlsx file with 5 dedicated sheets',
                                        style: TextStyle(
                                            fontSize: 12, color: AppTheme.textMuted)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Sheets included in export:\n'
                            '• Customers (National ID, Name, Phones, Address, Email)\n'
                            '• Services (Name, Category, Price, Date Provided, Notes)\n'
                            '• Activities (Timeline events, types, notes)\n'
                            '• Orders (Ordered items, total amounts, statuses)\n'
                            '• Bills (Amounts, paid, balance, due dates)',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.textDark, height: 1.5),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.successGreen),
                              icon: const Icon(Icons.file_download, size: 18),
                              label: const Text('Export .xlsx Now (P0-10)'),
                              onPressed: () {
                                excelCubit.exportData();
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
                                child: const Icon(Icons.upload_file,
                                    color: AppTheme.accentIndigo, size: 28),
                              ),
                              const SizedBox(width: 16),
                              const Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Import from Excel',
                                        style: TextStyle(
                                            fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text(
                                        'Upload customer spreadsheets with duplicate checks',
                                        style: TextStyle(
                                            fontSize: 12, color: AppTheme.textMuted)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Acceptance criteria verification (P0-11):\n'
                            '• Valid rows are parsed and persisted into SQLite\n'
                            '• Existing National IDs support Skip or Update strategies\n'
                            '• Malformed rows (short IDs, invalid phones) are isolated\n'
                            '• Valid rows persist without being blocked',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.textDark, height: 1.5),
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryBlue),
                              icon: const Icon(Icons.attach_file, size: 18),
                              label: const Text('Attach & Import Excel File (P0-11)'),
                              onPressed: () async {
                                final pickedPath = await DesktopFilePicker.pickExcelFile();
                                if (context.mounted) {
                                  final result = await showDialog<Map<String, dynamic>>(
                                    context: context,
                                    builder: (_) => ExcelImportDialog(initialFilePath: pickedPath),
                                  );

                                  if (result != null && result['filePath'] is String) {
                                    final filePath = result['filePath'] as String;
                                    final strategy =
                                        result['strategy'] as DuplicateStrategy? ??
                                            DuplicateStrategy.skip;

                                    await excelCubit.importFromFile(
                                      filePath: filePath,
                                      strategy: strategy,
                                    );

                                    // Refresh customer list after import
                                    customerCubit.loadCustomers();
                                  }
                                }
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
                            Text(state.operationMessage,
                                style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                if (state is ExcelIoError) {
                  return Card(
                    color: const Color(0xFFFEF2F2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Color(0xFFFECACA)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline, color: AppTheme.dangerRed, size: 28),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Excel Operation Failed',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        color: Color(0xFF991B1B))),
                                const SizedBox(height: 4),
                                Text(state.message,
                                    style: const TextStyle(
                                        fontSize: 13, color: Color(0xFF7F1D1D))),
                              ],
                            ),
                          ),
                        ],
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
                              const Icon(Icons.check_circle,
                                  color: AppTheme.successGreen, size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Export Successful: ${state.filename}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Color(0xFF14532D)),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'File saved on disk: ${state.filePath}',
                                      style: const TextStyle(
                                          fontSize: 12, color: Color(0xFF166534)),
                                    ),
                                  ],
                                ),
                              ),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.successGreen,
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(Icons.open_in_new, size: 16),
                                    label: const Text('Open File'),
                                    onPressed: () {
                                      DesktopFileLauncher.openFile(state.filePath);
                                    },
                                  ),
                                  OutlinedButton.icon(
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF14532D),
                                      side: const BorderSide(color: Color(0xFF86EFAC)),
                                    ),
                                    icon: const Icon(Icons.folder_open, size: 16),
                                    label: const Text('Show in Folder'),
                                    onPressed: () {
                                      DesktopFileLauncher.revealInFolder(state.filePath);
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Wrap(
                            spacing: 16,
                            runSpacing: 8,
                            children: [
                              _Pill(
                                  label: 'Customers: ${state.customersCount}',
                                  bg: const Color(0xFFDCFCE7),
                                  fg: const Color(0xFF166534)),
                              _Pill(
                                  label: 'Services: ${state.servicesCount}',
                                  bg: const Color(0xFFEFF6FF),
                                  fg: const Color(0xFF1E40AF)),
                              _Pill(
                                  label: 'Activities: ${state.activitiesCount}',
                                  bg: const Color(0xFFFEF3C7),
                                  fg: const Color(0xFF92400E)),
                              _Pill(
                                  label: 'Orders: ${state.ordersCount}',
                                  bg: const Color(0xFFF3E8FF),
                                  fg: const Color(0xFF6B21A8)),
                              _Pill(
                                  label: 'Bills: ${state.billsCount}',
                                  bg: const Color(0xFFFEE2E2),
                                  fg: const Color(0xFF991B1B)),
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
                          const Text('Import Execution Summary (P0-11)',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          const SizedBox(height: 12),

                          // Summary Pills
                          Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: [
                              _Pill(
                                  label: 'Total Spreadsheet Rows: ${report.totalRows}',
                                  bg: const Color(0xFFF1F5F9),
                                  fg: Colors.black87),
                              _Pill(
                                  label: 'New Customers Imported: ${report.importedCount}',
                                  bg: const Color(0xFFDCFCE7),
                                  fg: const Color(0xFF166534)),
                              if (report.updatedCount > 0)
                                _Pill(
                                    label: 'Existing Customers Updated: ${report.updatedCount}',
                                    bg: const Color(0xFFE0E7FF),
                                    fg: const Color(0xFF3730A3)),
                              _Pill(
                                  label:
                                      'Duplicate National IDs Flagged: ${report.duplicateCount}',
                                  bg: const Color(0xFFFEF3C7),
                                  fg: const Color(0xFF92400E)),
                              _Pill(
                                  label: 'Malformed Rows Rejected: ${report.malformedCount}',
                                  bg: const Color(0xFFFEE2E2),
                                  fg: const Color(0xFF991B1B)),
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
                                  const Icon(Icons.warning_amber,
                                      color: Color(0xFFD97706), size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      'Duplicate Conflict Detected: ${report.duplicateNationalIds.join(", ")} was skipped or flagged to prevent record duplication.',
                                      style: const TextStyle(
                                          color: Color(0xFF92400E), fontSize: 13),
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
                                  const Icon(Icons.error_outline,
                                      color: AppTheme.dangerRed, size: 20),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      report.malformedRowErrors.join('\n'),
                                      style: const TextStyle(
                                          color: Color(0xFF991B1B), fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Parsed rows table inspector
                          if (report.parsedRows.isNotEmpty) ...[
                            const Text('Parsed Rows Inspector:',
                                style:
                                    TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                  headingRowColor:
                                      WidgetStateProperty.all(const Color(0xFFF1F5F9)),
                                  columns: const [
                                    DataColumn(label: Text('Row #')),
                                    DataColumn(label: Text('National ID')),
                                    DataColumn(label: Text('Full Name')),
                                    DataColumn(label: Text('Phone Numbers')),
                                    DataColumn(label: Text('Status')),
                                    DataColumn(label: Text('Notes / Error Details')),
                                  ],
                                  rows: report.parsedRows.map((r) {
                                    final isError = r.status == ExcelRowStatus.malformed;
                                    final isDup =
                                        r.status == ExcelRowStatus.duplicateSkipped;
                                    final isUpdated = r.status == ExcelRowStatus.updated;

                                    Color statusBg = const Color(0xFFDCFCE7);
                                    Color statusFg = const Color(0xFF15803D);
                                    String statusLabel = 'Imported';

                                    if (isError) {
                                      statusBg = const Color(0xFFFEE2E2);
                                      statusFg = const Color(0xFFB91C1C);
                                      statusLabel = 'Malformed';
                                    } else if (isDup) {
                                      statusBg = const Color(0xFFFEF3C7);
                                      statusFg = const Color(0xFFB45309);
                                      statusLabel = 'Duplicate';
                                    } else if (isUpdated) {
                                      statusBg = const Color(0xFFE0E7FF);
                                      statusFg = const Color(0xFF3730A3);
                                      statusLabel = 'Updated';
                                    }

                                    return DataRow(
                                      cells: [
                                        DataCell(Text('${r.rowNumber}')),
                                        DataCell(Text(r.nationalId)),
                                        DataCell(Text(r.fullName)),
                                        DataCell(Text(r.phoneNumbers.join(', '))),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: statusBg,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              statusLabel,
                                              style: TextStyle(
                                                color: statusFg,
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                        DataCell(
                                          Text(
                                            r.errorMessage ?? 'Persisted to SQLite',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isError
                                                  ? AppTheme.dangerRed
                                                  : (isDup
                                                      ? const Color(0xFFB45309)
                                                      : AppTheme.textMuted),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
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
      child: Text(label,
          style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }
}
