import 'package:fpdart/fpdart.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../activity/domain/repositories/activity_repository.dart';
import '../../../billing/domain/repositories/billing_repository.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../../customer/domain/repositories/customer_repository.dart';
import '../../../order/domain/repositories/order_repository.dart';
import '../../../service/domain/repositories/service_repository.dart';
import '../../domain/entities/duplicate_strategy.dart';
import '../../domain/entities/excel_export_result.dart';
import '../../domain/entities/excel_import_report.dart';
import '../../domain/entities/excel_parsed_row.dart';
import '../../domain/repositories/excel_io_repository.dart';
import '../datasources/excel_local_datasource.dart';

class ExcelIoRepositoryImpl implements ExcelIoRepository {
  final ExcelLocalDatasource localDatasource;
  final CustomerRepository customerRepository;
  final ServiceRepository serviceRepository;
  final ActivityRepository activityRepository;
  final OrderRepository orderRepository;
  final BillingRepository billingRepository;

  ExcelIoRepositoryImpl({
    required this.localDatasource,
    required this.customerRepository,
    required this.serviceRepository,
    required this.activityRepository,
    required this.orderRepository,
    required this.billingRepository,
  });

  @override
  Future<Either<Failure, ExcelExportResult>> exportAllData({String? targetDirectory}) async {
    try {
      final custResult = await customerRepository.getCustomers();
      final customers = custResult.fold((f) => throw DatabaseException(f.message), (r) => r);

      final servResult = await serviceRepository.getAllServices();
      final services = servResult.fold((f) => throw DatabaseException(f.message), (r) => r);

      final actResult = await activityRepository.getAllActivities();
      final activities = actResult.fold((f) => throw DatabaseException(f.message), (r) => r);

      final ordResult = await orderRepository.getAllOrders();
      final orders = ordResult.fold((f) => throw DatabaseException(f.message), (r) => r);

      final billResult = await billingRepository.getAllBills();
      final bills = billResult.fold((f) => throw DatabaseException(f.message), (r) => r);

      final bytes = await localDatasource.generateWorkbookBytes(
        customers: customers,
        services: services,
        activities: activities,
        orders: orders,
        bills: bills,
      );

      final savedFile = await localDatasource.saveWorkbookToFile(
        bytes: bytes,
        targetDirectory: targetDirectory,
      );

      final fileName = savedFile.uri.pathSegments.last;

      return Right(ExcelExportResult(
        filePath: savedFile.path,
        fileName: fileName,
        customersCount: customers.length,
        servicesCount: services.length,
        activitiesCount: activities.length,
        ordersCount: orders.length,
        billsCount: bills.length,
        exportedAt: DateTime.now(),
      ));
    } catch (e) {
      if (e is DatabaseException) {
        return Left(DatabaseFailure(e.message));
      }
      return Left(ExcelFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExcelImportReport>> importCustomersFromFile({
    required String filePath,
    required DuplicateStrategy strategy,
  }) async {
    try {
      final sheetData = await localDatasource.parseSpreadsheetFile(filePath);
      return _processParsedSheet(sheetData, strategy);
    } catch (e) {
      return Left(ExcelFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ExcelImportReport>> importCustomersFromBytes({
    required List<int> bytes,
    required DuplicateStrategy strategy,
  }) async {
    try {
      final sheetData = await localDatasource.parseSpreadsheetBytes(bytes);
      return _processParsedSheet(sheetData, strategy);
    } catch (e) {
      return Left(ExcelFailure(e.toString()));
    }
  }

  Future<Either<Failure, ExcelImportReport>> _processParsedSheet(
    ExcelParsedSheetData sheetData,
    DuplicateStrategy strategy,
  ) async {
    int importedCount = 0;
    int updatedCount = 0;
    final duplicateNationalIds = <String>[];
    final malformedErrors = List<String>.from(sheetData.malformedErrors);
    final parsedRows = <ExcelParsedRow>[];

    for (int i = 0; i < sheetData.rows.length; i++) {
      final rawRow = sheetData.rows[i];

      if (!rawRow.isValid) {
        parsedRows.add(ExcelParsedRow(
          rowNumber: rawRow.rowNumber,
          nationalId: rawRow.nationalId,
          fullName: rawRow.fullName,
          phoneNumbers: rawRow.phoneNumbers,
          address: rawRow.address,
          email: rawRow.email,
          status: ExcelRowStatus.malformed,
          errorMessage: rawRow.errorMessage,
        ));
        continue;
      }

      // Check if National ID exists in CustomerRepository
      final existingRes = await customerRepository.getCustomerByNationalId(rawRow.nationalId);
      final Customer? existingCustomer = existingRes.fold((_) => null, (c) => c);

      if (existingCustomer != null) {
        if (strategy == DuplicateStrategy.skip) {
          duplicateNationalIds.add('${rawRow.nationalId} (${existingCustomer.fullName})');
          parsedRows.add(ExcelParsedRow(
            rowNumber: rawRow.rowNumber,
            nationalId: rawRow.nationalId,
            fullName: rawRow.fullName,
            phoneNumbers: rawRow.phoneNumbers,
            address: rawRow.address,
            email: rawRow.email,
            status: ExcelRowStatus.duplicateSkipped,
            errorMessage: 'Duplicate National ID (Already in Database)',
          ));
        } else {
          // Update strategy: merge phone numbers and update fields
          final combinedPhones = {
            ...existingCustomer.phoneNumbers,
            ...rawRow.phoneNumbers,
          }.toList();

          final updatedCustomer = existingCustomer.copyWith(
            fullName: rawRow.fullName.isNotEmpty ? rawRow.fullName : existingCustomer.fullName,
            phoneNumbers: combinedPhones,
            address: rawRow.address ?? existingCustomer.address,
            email: rawRow.email ?? existingCustomer.email,
            updatedAt: DateTime.now(),
          );

          final updateResult = await customerRepository.updateCustomer(updatedCustomer);
          updateResult.fold(
            (f) {
              malformedErrors.add('Row ${rawRow.rowNumber}: Failed to update customer (${f.message}).');
              parsedRows.add(ExcelParsedRow(
                rowNumber: rawRow.rowNumber,
                nationalId: rawRow.nationalId,
                fullName: rawRow.fullName,
                phoneNumbers: rawRow.phoneNumbers,
                address: rawRow.address,
                email: rawRow.email,
                status: ExcelRowStatus.malformed,
                errorMessage: f.message,
              ));
            },
            (_) {
              updatedCount++;
              parsedRows.add(ExcelParsedRow(
                rowNumber: rawRow.rowNumber,
                nationalId: rawRow.nationalId,
                fullName: rawRow.fullName,
                phoneNumbers: rawRow.phoneNumbers,
                address: rawRow.address,
                email: rawRow.email,
                status: ExcelRowStatus.updated,
              ));
            },
          );
        }
      } else {
        // New customer record
        final newCustomer = Customer(
          id: 'cust_imp_${DateTime.now().millisecondsSinceEpoch}_$i',
          nationalId: rawRow.nationalId,
          fullName: rawRow.fullName,
          phoneNumbers: rawRow.phoneNumbers,
          address: rawRow.address,
          email: rawRow.email,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final createResult = await customerRepository.createCustomer(newCustomer);
        createResult.fold(
          (f) {
            malformedErrors.add('Row ${rawRow.rowNumber}: Failed to save customer (${f.message}).');
            parsedRows.add(ExcelParsedRow(
              rowNumber: rawRow.rowNumber,
              nationalId: rawRow.nationalId,
              fullName: rawRow.fullName,
              phoneNumbers: rawRow.phoneNumbers,
              address: rawRow.address,
              email: rawRow.email,
              status: ExcelRowStatus.malformed,
              errorMessage: f.message,
            ));
          },
          (_) {
            importedCount++;
            parsedRows.add(ExcelParsedRow(
              rowNumber: rawRow.rowNumber,
              nationalId: rawRow.nationalId,
              fullName: rawRow.fullName,
              phoneNumbers: rawRow.phoneNumbers,
              address: rawRow.address,
              email: rawRow.email,
              status: ExcelRowStatus.imported,
            ));
          },
        );
      }
    }

    return Right(ExcelImportReport(
      totalRows: sheetData.rows.length,
      importedCount: importedCount,
      updatedCount: updatedCount,
      duplicateNationalIds: duplicateNationalIds,
      malformedRowErrors: malformedErrors,
      parsedRows: parsedRows,
    ));
  }
}
