import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../../core/error/exceptions.dart';
import '../../../activity/domain/entities/activity.dart';
import '../../../billing/domain/entities/bill.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../../order/domain/entities/order.dart';
import '../../../service/domain/entities/service_item.dart';

class RawParsedCustomerRow {
  final int rowNumber;
  final String nationalId;
  final String fullName;
  final List<String> phoneNumbers;
  final String? address;
  final String? email;
  final bool isValid;
  final String? errorMessage;

  const RawParsedCustomerRow({
    required this.rowNumber,
    required this.nationalId,
    required this.fullName,
    required this.phoneNumbers,
    this.address,
    this.email,
    required this.isValid,
    this.errorMessage,
  });
}

class ExcelParsedSheetData {
  final List<RawParsedCustomerRow> rows;
  final List<String> malformedErrors;

  const ExcelParsedSheetData({
    required this.rows,
    required this.malformedErrors,
  });
}

abstract class ExcelLocalDatasource {
  Future<List<int>> generateWorkbookBytes({
    required List<Customer> customers,
    required List<ServiceItem> services,
    required List<Activity> activities,
    required List<Orders> orders,
    required List<Bill> bills,
  });

  Future<File> saveWorkbookToFile({
    required List<int> bytes,
    String? targetDirectory,
    String? customFileName,
  });

  Future<ExcelParsedSheetData> parseSpreadsheetBytes(List<int> bytes);

  Future<ExcelParsedSheetData> parseSpreadsheetFile(String filePath);
}

class ExcelLocalDatasourceImpl implements ExcelLocalDatasource {
  @override
  Future<List<int>> generateWorkbookBytes({
    required List<Customer> customers,
    required List<ServiceItem> services,
    required List<Activity> activities,
    required List<Orders> orders,
    required List<Bill> bills,
  }) async {
    try {
      final excel = Excel.createExcel();

      // 1. Customers Sheet
      final customersSheet = excel['Customers'];
      customersSheet.appendRow([
        TextCellValue('Customer ID'),
        TextCellValue('National ID'),
        TextCellValue('Full Name'),
        TextCellValue('Phone Numbers'),
        TextCellValue('Address'),
        TextCellValue('Email'),
        TextCellValue('Created At'),
        TextCellValue('Updated At'),
      ]);

      for (final c in customers) {
        customersSheet.appendRow([
          TextCellValue(c.id),
          TextCellValue(c.nationalId),
          TextCellValue(c.fullName),
          TextCellValue(c.phoneNumbers.join(', ')),
          TextCellValue(c.address ?? ''),
          TextCellValue(c.email ?? ''),
          TextCellValue(c.createdAt.toIso8601String()),
          TextCellValue(c.updatedAt.toIso8601String()),
        ]);
      }

      // 2. Services Sheet
      final servicesSheet = excel['Services'];
      servicesSheet.appendRow([
        TextCellValue('Service ID'),
        TextCellValue('Customer ID'),
        TextCellValue('Service Name'),
        TextCellValue('Category'),
        TextCellValue('Price (EGP)'),
        TextCellValue('Date Provided'),
        TextCellValue('Notes'),
      ]);

      for (final s in services) {
        servicesSheet.appendRow([
          TextCellValue(s.id),
          TextCellValue(s.customerId),
          TextCellValue(s.name),
          TextCellValue(s.category),
          DoubleCellValue(s.price),
          TextCellValue(s.dateProvided.toIso8601String()),
          TextCellValue(s.notes ?? ''),
        ]);
      }

      // 3. Activities Sheet
      final activitiesSheet = excel['Activities'];
      activitiesSheet.appendRow([
        TextCellValue('Activity ID'),
        TextCellValue('Customer ID'),
        TextCellValue('Activity Type'),
        TextCellValue('Note'),
        TextCellValue('Timestamp'),
      ]);

      for (final a in activities) {
        activitiesSheet.appendRow([
          TextCellValue(a.id),
          TextCellValue(a.customerId),
          TextCellValue(a.type.name),
          TextCellValue(a.note),
          TextCellValue(a.timestamp.toIso8601String()),
        ]);
      }

      // 4. Orders Sheet
      final ordersSheet = excel['Orders'];
      ordersSheet.appendRow([
        TextCellValue('Order ID'),
        TextCellValue('Customer ID'),
        TextCellValue('Items'),
        TextCellValue('Status'),
        TextCellValue('Total Amount (EGP)'),
        TextCellValue('Created At'),
        TextCellValue('Updated At'),
      ]);

      for (final o in orders) {
        ordersSheet.appendRow([
          TextCellValue(o.id),
          TextCellValue(o.customerId),
          TextCellValue(o.items.join('; ')),
          TextCellValue(o.status.name),
          DoubleCellValue(o.totalAmount),
          TextCellValue(o.createdAt.toIso8601String()),
          TextCellValue(o.updatedAt.toIso8601String()),
        ]);
      }

      // 5. Bills Sheet
      final billsSheet = excel['Bills'];
      billsSheet.appendRow([
        TextCellValue('Bill ID'),
        TextCellValue('Customer ID'),
        TextCellValue('Amount (EGP)'),
        TextCellValue('Paid Amount (EGP)'),
        TextCellValue('Balance (EGP)'),
        TextCellValue('Status'),
        TextCellValue('Due Date'),
        TextCellValue('Issued At'),
        TextCellValue('Description'),
      ]);

      for (final b in bills) {
        billsSheet.appendRow([
          TextCellValue(b.id),
          TextCellValue(b.customerId),
          DoubleCellValue(b.amount),
          DoubleCellValue(b.paidAmount),
          DoubleCellValue(b.remainingAmount),
          TextCellValue(b.status.name),
          TextCellValue(b.dueDate.toIso8601String()),
          TextCellValue(b.issuedAt.toIso8601String()),
          TextCellValue(b.description ?? ''),
        ]);
      }

      // Delete default 'Sheet1' created by package:excel
      if (excel.tables.containsKey('Sheet1')) {
        excel.delete('Sheet1');
      }

      final encoded = excel.encode();
      if (encoded == null) {
        throw const ExcelException('Failed to encode Excel workbook to bytes.');
      }
      return encoded;
    } catch (e) {
      if (e is ExcelException) rethrow;
      throw ExcelException('Excel generation failed: $e');
    }
  }

  @override
  Future<File> saveWorkbookToFile({
    required List<int> bytes,
    String? targetDirectory,
    String? customFileName,
  }) async {
    try {
      Directory exportDir;
      if (targetDirectory != null && targetDirectory.trim().isNotEmpty) {
        exportDir = Directory(targetDirectory);
      } else {
        try {
          final downloadsDir = await getDownloadsDirectory();
          exportDir = downloadsDir ?? await getApplicationDocumentsDirectory();
        } catch (_) {
          exportDir = await getApplicationDocumentsDirectory();
        }
      }

      if (!await exportDir.exists()) {
        await exportDir.create(recursive: true);
      }

      final now = DateTime.now();
      final defaultName =
          'CRM_Export_${now.year}_${now.month.toString().padLeft(2, '0')}_${now.day.toString().padLeft(2, '0')}_${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}.xlsx';

      final finalFileName = (customFileName != null && customFileName.trim().isNotEmpty)
          ? customFileName
          : defaultName;

      final fullPath = p.join(exportDir.path, finalFileName);
      final file = File(fullPath);
      await file.writeAsBytes(bytes, flush: true);
      return file;
    } catch (e) {
      throw ExcelException('Failed to save Excel file to disk: $e');
    }
  }

  @override
  Future<ExcelParsedSheetData> parseSpreadsheetFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw ExcelException('Excel file not found at "$filePath".');
      }
      final bytes = await file.readAsBytes();
      return parseSpreadsheetBytes(bytes);
    } catch (e) {
      if (e is ExcelException) rethrow;
      throw ExcelException('Failed reading Excel file: $e');
    }
  }

  @override
  Future<ExcelParsedSheetData> parseSpreadsheetBytes(List<int> bytes) async {
    try {
      final excel = Excel.decodeBytes(bytes);
      if (excel.tables.isEmpty) {
        throw const ExcelException('The provided Excel file has no sheets.');
      }

      // Locate customer sheet
      String? customerSheetName;
      for (final name in excel.tables.keys) {
        final lower = name.toLowerCase().trim();
        if (lower == 'customers' || lower == 'customer' || lower == 'العملاء' || lower == 'عملاء') {
          customerSheetName = name;
          break;
        }
      }
      customerSheetName ??= excel.tables.keys.first;

      final sheet = excel.tables[customerSheetName];
      if (sheet == null || sheet.rows.isEmpty) {
        throw ExcelException('Sheet "$customerSheetName" is empty.');
      }

      final headerRow = sheet.rows.first;
      int nationalIdCol = -1;
      int fullNameCol = -1;
      int phoneCol = -1;
      int addressCol = -1;
      int emailCol = -1;

      for (int i = 0; i < headerRow.length; i++) {
        final val = _extractCellString(headerRow[i]).toLowerCase().trim();
        if (val.contains('national') || val.contains('رقم قومي') || val.contains('الرقم القومي')) {
          nationalIdCol = i;
        } else if (val.contains('name') || val.contains('اسم') || val.contains('الاسم')) {
          fullNameCol = i;
        } else if (val.contains('phone') || val.contains('mobile') || val.contains('هاتف') || val.contains('موبايل')) {
          phoneCol = i;
        } else if (val.contains('address') || val.contains('عنوان') || val.contains('العنوان')) {
          addressCol = i;
        } else if (val.contains('email') || val.contains('بريد')) {
          emailCol = i;
        }
      }

      // Default column mapping if headers weren't found by name
      if (nationalIdCol == -1 && headerRow.length > 0) nationalIdCol = 0;
      if (fullNameCol == -1 && headerRow.length > 1) fullNameCol = 1;
      if (phoneCol == -1 && headerRow.length > 2) phoneCol = 2;
      if (addressCol == -1 && headerRow.length > 3) addressCol = 3;
      if (emailCol == -1 && headerRow.length > 4) emailCol = 4;

      final parsedRows = <RawParsedCustomerRow>[];
      final malformedErrors = <String>[];

      // Parse data rows (skipping header at index 0)
      for (int rowIndex = 1; rowIndex < sheet.rows.length; rowIndex++) {
        final row = sheet.rows[rowIndex];
        if (_isRowEmpty(row)) continue;

        final rowNumber = rowIndex + 1; // 1-based index for user display
        final rawNationalId = nationalIdCol >= 0 && nationalIdCol < row.length
            ? _extractCellString(row[nationalIdCol])
            : '';
        final rawFullName = fullNameCol >= 0 && fullNameCol < row.length
            ? _extractCellString(row[fullNameCol])
            : '';
        final rawPhone = phoneCol >= 0 && phoneCol < row.length
            ? _extractCellString(row[phoneCol])
            : '';
        final rawAddress = addressCol >= 0 && addressCol < row.length
            ? _extractCellString(row[addressCol])
            : '';
        final rawEmail = emailCol >= 0 && emailCol < row.length
            ? _extractCellString(row[emailCol])
            : '';

        final rowValidationErrors = <String>[];

        // 1. National ID validation (14 digits)
        final cleanNationalId = rawNationalId.replaceAll(RegExp(r'\s|-'), '');
        if (cleanNationalId.isEmpty) {
          rowValidationErrors.add('National ID is required');
        } else if (!RegExp(r'^\d{14}$').hasMatch(cleanNationalId)) {
          rowValidationErrors.add(
              'National ID "$rawNationalId" must be exactly 14 digits (got ${cleanNationalId.length})');
        }

        // 2. Full Name validation
        final cleanName = rawFullName.trim();
        if (cleanName.isEmpty) {
          rowValidationErrors.add('Full Name is required');
        }

        // 3. Phone validation
        final rawPhonesList = rawPhone
            .split(RegExp(r'[,;/]'))
            .map((p) => p.trim())
            .where((p) => p.isNotEmpty)
            .toList();

        final validPhones = <String>[];
        if (rawPhonesList.isEmpty) {
          rowValidationErrors.add('At least one phone number is required');
        } else {
          for (final p in rawPhonesList) {
            var digits = p.replaceAll(RegExp(r'\s|-'), '');
            if (digits.startsWith('+20')) {
              digits = '0${digits.substring(3)}';
            } else if (digits.startsWith('0020')) {
              digits = '0${digits.substring(4)}';
            }
            if (RegExp(r'^01[0125]\d{8}$').hasMatch(digits)) {
              validPhones.add(digits);
            } else {
              rowValidationErrors.add(
                  'Phone "$p" is not a valid Egyptian mobile format (01[0-2,5]XXXXXXXX)');
            }
          }
        }

        final isValid = rowValidationErrors.isEmpty;
        final errorMsg = isValid ? null : 'Row $rowNumber: ${rowValidationErrors.join("; ")}.';
        if (!isValid) {
          malformedErrors.add(errorMsg!);
        }

        parsedRows.add(RawParsedCustomerRow(
          rowNumber: rowNumber,
          nationalId: cleanNationalId.isNotEmpty ? cleanNationalId : rawNationalId,
          fullName: cleanName.isNotEmpty ? cleanName : rawFullName,
          phoneNumbers: validPhones.isNotEmpty ? validPhones : rawPhonesList,
          address: rawAddress.trim().isNotEmpty ? rawAddress.trim() : null,
          email: rawEmail.trim().isNotEmpty ? rawEmail.trim() : null,
          isValid: isValid,
          errorMessage: errorMsg,
        ));
      }

      return ExcelParsedSheetData(
        rows: parsedRows,
        malformedErrors: malformedErrors,
      );
    } catch (e) {
      if (e is ExcelException) rethrow;
      throw ExcelException('Error parsing Excel spreadsheet: $e');
    }
  }

  String _extractCellString(Data? cell) {
    if (cell == null || cell.value == null) return '';
    final val = cell.value;
    if (val is TextCellValue) {
      return val.value.text ?? '';
    }
    return val.toString().trim();
  }

  bool _isRowEmpty(List<Data?> row) {
    if (row.isEmpty) return true;
    for (final cell in row) {
      if (cell != null && cell.value != null && _extractCellString(cell).trim().isNotEmpty) {
        return false;
      }
    }
    return true;
  }
}
