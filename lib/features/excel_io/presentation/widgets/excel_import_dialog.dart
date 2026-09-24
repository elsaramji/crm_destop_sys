import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:excel/excel.dart' hide Border;

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/desktop_file_picker.dart';
import '../../domain/entities/duplicate_strategy.dart';

class ExcelImportDialog extends StatefulWidget {
  final String? initialFilePath;
  const ExcelImportDialog({super.key, this.initialFilePath});

  @override
  State<ExcelImportDialog> createState() => _ExcelImportDialogState();
}

class _ExcelImportDialogState extends State<ExcelImportDialog> {
  final _pathController = TextEditingController();
  DuplicateStrategy _selectedStrategy = DuplicateStrategy.skip;
  String? _errorMessage;
  bool _isGeneratingSample = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialFilePath != null && widget.initialFilePath!.isNotEmpty) {
      _pathController.text = widget.initialFilePath!;
    } else {
      final workspaceFile = File('customers_50_test.xlsx');
      if (workspaceFile.existsSync()) {
        _pathController.text = workspaceFile.absolute.path;
      }
    }
  }

  @override
  void dispose() {
    _pathController.dispose();
    super.dispose();
  }

  Future<void> _pickExcelFile() async {
    final path = await DesktopFilePicker.pickExcelFile();
    if (path != null && mounted) {
      setState(() {
        _pathController.text = path;
        _errorMessage = null;
      });
    }
  }

  Future<void> _generateSampleExcelFile() async {
    setState(() {
      _isGeneratingSample = true;
      _errorMessage = null;
    });

    try {
      final docsDir = await getApplicationDocumentsDirectory();
      final samplePath = p.join(docsDir.path, 'CRM_Sample_Import.xlsx');

      final excel = Excel.createExcel();
      final sheet = excel['Customers'];

      // Header row
      sheet.appendRow([
        TextCellValue('National ID'),
        TextCellValue('Full Name'),
        TextCellValue('Phone Numbers'),
        TextCellValue('Address'),
        TextCellValue('Email'),
      ]);

      // 1. Valid new customer 1
      sheet.appendRow([
        TextCellValue('29602021408899'),
        TextCellValue('Ibrahim Samir Qasim'),
        TextCellValue('01099887766'),
        TextCellValue('Nasr City, Cairo'),
        TextCellValue('ibrahim.samir@example.com'),
      ]);

      // 2. Duplicate National ID (Ahmed Mahmoud Hassan from initial DB seeds)
      sheet.appendRow([
        TextCellValue('29501011234567'),
        TextCellValue('Ahmed Mahmoud Hassan Updated'),
        TextCellValue('01012345678, 01299887766'),
        TextCellValue('New Cairo, Cairo'),
        TextCellValue('ahmed.updated@example.com'),
      ]);

      // 3. Valid new customer 2
      sheet.appendRow([
        TextCellValue('29811111903344'),
        TextCellValue('Nourhan Essam Tawfik'),
        TextCellValue('01155443322'),
        TextCellValue('Mohandessin, Giza'),
        TextCellValue('nourhan.essam@example.com'),
      ]);

      // 4. Malformed row 1: short National ID and invalid phone
      sheet.appendRow([
        TextCellValue('291030'), // Short ID
        TextCellValue('Hossam Badran'),
        TextCellValue('01999999999'), // Invalid Egyptian prefix (019)
        TextCellValue('Alexandria'),
        TextCellValue('hossam@example.com'),
      ]);

      // 5. Malformed row 2: missing name
      sheet.appendRow([
        TextCellValue('29901010101010'),
        TextCellValue(''), // Missing Name
        TextCellValue('01511223344'),
        TextCellValue('Tanta'),
        TextCellValue('tanta@example.com'),
      ]);

      if (excel.tables.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      final bytes = excel.encode();
      if (bytes != null) {
        final file = File(samplePath);
        await file.writeAsBytes(bytes, flush: true);
        setState(() {
          _pathController.text = samplePath;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to generate sample Excel file: $e';
      });
    } finally {
      setState(() {
        _isGeneratingSample = false;
      });
    }
  }

  void _onConfirm() {
    final path = _pathController.text.trim();
    if (path.isEmpty) {
      setState(() {
        _errorMessage = 'Please attach or select an Excel spreadsheet (.xlsx).';
      });
      return;
    }

    final file = File(path);
    if (!file.existsSync()) {
      setState(() {
        _errorMessage = 'File does not exist at specified path. Please verify the location.';
      });
      return;
    }

    if (!path.toLowerCase().endsWith('.xlsx') &&
        !path.toLowerCase().endsWith('.xls')) {
      setState(() {
        _errorMessage =
            'The selected file must be an Excel spreadsheet (.xlsx).';
      });
      return;
    }

    Navigator.of(context)
        .pop({'filePath': path, 'strategy': _selectedStrategy});
  }

  @override
  Widget build(BuildContext context) {
    final hasAttachedFile = _pathController.text.isNotEmpty && File(_pathController.text).existsSync();

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.file_upload,
                      color: AppTheme.primaryBlue,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Import Customers from Excel',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Select an Excel file (.xlsx) using the native file picker',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // File Picker / Attach Row
              const Text(
                'Excel Spreadsheet (.xlsx):',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _pathController,
                      decoration: InputDecoration(
                        hintText: r'Choose .xlsx file via File Picker...',
                        prefixIcon: const Icon(
                          Icons.insert_drive_file_outlined,
                          size: 20,
                        ),
                        suffixIcon: _pathController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () => setState(() => _pathController.clear()),
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryBlue,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                    ),
                    icon: const Icon(Icons.attach_file, size: 18),
                    label: const Text('Browse File'),
                    onPressed: _pickExcelFile,
                  ),
                ],
              ),

              // Attached file feedback chip
              if (hasAttachedFile) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 16),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ready to import: ${p.basename(_pathController.text)}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF14532D),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 10),

              // Sample file generator helper
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _isGeneratingSample
                      ? null
                      : _generateSampleExcelFile,
                  icon: _isGeneratingSample
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_fix_high, size: 16),
                  label: const Text(
                    'Generate & Load Edge-Case Sample (with Duplicates & Errors)',
                    style: TextStyle(fontSize: 11),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Duplicate Strategy Selection (PRD §10 Open Question & rules.md §5 Strategy Pattern)
              const Text(
                'Duplicate Conflict Resolution (Matched by National ID):',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.borderSubtle),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    RadioListTile<DuplicateStrategy>(
                      value: DuplicateStrategy.skip,
                      groupValue: _selectedStrategy,
                      onChanged: (val) =>
                          setState(() => _selectedStrategy = val!),
                      title: const Text(
                        'Skip Duplicate Records (Recommended)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Keep existing database records intact; log duplicates in the summary report.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      dense: true,
                    ),
                    const Divider(height: 1),
                    RadioListTile<DuplicateStrategy>(
                      value: DuplicateStrategy.update,
                      groupValue: _selectedStrategy,
                      onChanged: (val) =>
                          setState(() => _selectedStrategy = val!),
                      title: const Text(
                        'Update Existing Records',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: const Text(
                        'Merge phone numbers and overwrite contact fields with imported spreadsheet data.',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      dense: true,
                    ),
                  ],
                ),
              ),

              // Error banner if any
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFECACA)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppTheme.dangerRed,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(
                            color: Color(0xFF991B1B),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  const SizedBox(width: 12),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: const Text('Run Real Import'),
                    onPressed: _onConfirm,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
