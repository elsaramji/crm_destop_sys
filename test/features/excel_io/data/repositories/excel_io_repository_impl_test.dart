import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crm_destop_sys/core/error/failures.dart';
import 'package:crm_destop_sys/features/activity/domain/repositories/activity_repository.dart';
import 'package:crm_destop_sys/features/billing/domain/repositories/billing_repository.dart';
import 'package:crm_destop_sys/features/customer/domain/entities/customer.dart';
import 'package:crm_destop_sys/features/customer/domain/repositories/customer_repository.dart';
import 'package:crm_destop_sys/features/excel_io/data/datasources/excel_local_datasource.dart';
import 'package:crm_destop_sys/features/excel_io/data/repositories/excel_io_repository_impl.dart';
import 'package:crm_destop_sys/features/excel_io/domain/entities/duplicate_strategy.dart';
import 'package:crm_destop_sys/features/excel_io/domain/entities/excel_parsed_row.dart';
import 'package:crm_destop_sys/features/order/domain/repositories/order_repository.dart';
import 'package:crm_destop_sys/features/service/domain/repositories/service_repository.dart';

class MockExcelLocalDatasource extends Mock implements ExcelLocalDatasource {}
class MockCustomerRepository extends Mock implements CustomerRepository {}
class MockServiceRepository extends Mock implements ServiceRepository {}
class MockActivityRepository extends Mock implements ActivityRepository {}
class MockOrderRepository extends Mock implements OrderRepository {}
class MockBillingRepository extends Mock implements BillingRepository {}
class MockFile extends Mock implements File {}

void main() {
  late ExcelIoRepositoryImpl repository;
  late MockExcelLocalDatasource mockDatasource;
  late MockCustomerRepository mockCustomerRepo;
  late MockServiceRepository mockServiceRepo;
  late MockActivityRepository mockActivityRepo;
  late MockOrderRepository mockOrderRepo;
  late MockBillingRepository mockBillingRepo;

  setUp(() {
    mockDatasource = MockExcelLocalDatasource();
    mockCustomerRepo = MockCustomerRepository();
    mockServiceRepo = MockServiceRepository();
    mockActivityRepo = MockActivityRepository();
    mockOrderRepo = MockOrderRepository();
    mockBillingRepo = MockBillingRepository();

    repository = ExcelIoRepositoryImpl(
      localDatasource: mockDatasource,
      customerRepository: mockCustomerRepo,
      serviceRepository: mockServiceRepo,
      activityRepository: mockActivityRepo,
      orderRepository: mockOrderRepo,
      billingRepository: mockBillingRepo,
    );

    registerFallbackValue(Customer(
      id: 'fallback',
      nationalId: '29501011234567',
      fullName: 'Fallback',
      phoneNumbers: const ['01012345678'],
      createdAt: DateTime(2026),
      updatedAt: DateTime(2026),
    ));
  });

  group('exportAllData', () {
    test('should fetch all data from all repositories, generate bytes, and save to file', () async {
      when(() => mockCustomerRepo.getCustomers()).thenAnswer((_) async => const Right([]));
      when(() => mockServiceRepo.getAllServices()).thenAnswer((_) async => const Right([]));
      when(() => mockActivityRepo.getAllActivities()).thenAnswer((_) async => const Right([]));
      when(() => mockOrderRepo.getAllOrders()).thenAnswer((_) async => const Right([]));
      when(() => mockBillingRepo.getAllBills()).thenAnswer((_) async => const Right([]));

      final bytes = [10, 20, 30];
      when(() => mockDatasource.generateWorkbookBytes(
            customers: any(named: 'customers'),
            services: any(named: 'services'),
            activities: any(named: 'activities'),
            orders: any(named: 'orders'),
            bills: any(named: 'bills'),
          )).thenAnswer((_) async => bytes);

      final mockFile = MockFile();
      when(() => mockFile.path).thenReturn('C:/Exports/CRM_Export.xlsx');
      when(() => mockFile.uri).thenReturn(Uri.file('C:/Exports/CRM_Export.xlsx'));

      when(() => mockDatasource.saveWorkbookToFile(
            bytes: bytes,
            targetDirectory: 'C:/Exports',
          )).thenAnswer((_) async => mockFile);

      final result = await repository.exportAllData(targetDirectory: 'C:/Exports');

      expect(result.isRight(), isTrue);
      result.fold(
        (f) => fail('Expected Right'),
        (r) {
          expect(r.filePath, 'C:/Exports/CRM_Export.xlsx');
          expect(r.fileName, 'CRM_Export.xlsx');
        },
      );
    });

    test('should return DatabaseFailure when customer repository fails', () async {
      when(() => mockCustomerRepo.getCustomers())
          .thenAnswer((_) async => const Left(DatabaseFailure('DB read failed')));

      final result = await repository.exportAllData();

      expect(result.isLeft(), isTrue);
      result.fold(
        (f) => expect(f, isA<DatabaseFailure>()),
        (_) => fail('Expected Left'),
      );
    });
  });

  group('importCustomersFromFile', () {
    final existingCustomer = Customer(
      id: 'cust_1',
      nationalId: '29501011234567',
      fullName: 'Ahmed Hassan',
      phoneNumbers: const ['01012345678'],
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    test('should skip duplicates when strategy is DuplicateStrategy.skip', () async {
      const sheetData = ExcelParsedSheetData(
        rows: [
          RawParsedCustomerRow(
            rowNumber: 2,
            nationalId: '29501011234567', // Duplicate
            fullName: 'Ahmed Hassan Duplicate',
            phoneNumbers: ['01012345678'],
            isValid: true,
          ),
          RawParsedCustomerRow(
            rowNumber: 3,
            nationalId: '29602021408899', // New
            fullName: 'Ibrahim Samir',
            phoneNumbers: ['01099887766'],
            isValid: true,
          ),
          RawParsedCustomerRow(
            rowNumber: 4,
            nationalId: '2910', // Malformed
            fullName: 'Bad Row',
            phoneNumbers: ['invalid'],
            isValid: false,
            errorMessage: 'Row 4: National ID must be 14 digits.',
          ),
        ],
        malformedErrors: ['Row 4: National ID must be 14 digits.'],
      );

      when(() => mockDatasource.parseSpreadsheetFile('C:/test.xlsx'))
          .thenAnswer((_) async => sheetData);

      when(() => mockCustomerRepo.getCustomerByNationalId('29501011234567'))
          .thenAnswer((_) async => Right(existingCustomer));

      when(() => mockCustomerRepo.getCustomerByNationalId('29602021408899'))
          .thenAnswer((_) async => const Right(null));

      when(() => mockCustomerRepo.createCustomer(any()))
          .thenAnswer((invocation) async => Right(invocation.positionalArguments.first as Customer));

      final result = await repository.importCustomersFromFile(
        filePath: 'C:/test.xlsx',
        strategy: DuplicateStrategy.skip,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (f) => fail('Expected Right'),
        (report) {
          expect(report.totalRows, 3);
          expect(report.importedCount, 1);
          expect(report.updatedCount, 0);
          expect(report.duplicateCount, 1);
          expect(report.malformedCount, 1);
          expect(report.parsedRows[0].status, ExcelRowStatus.duplicateSkipped);
          expect(report.parsedRows[1].status, ExcelRowStatus.imported);
          expect(report.parsedRows[2].status, ExcelRowStatus.malformed);
        },
      );

      verifyNever(() => mockCustomerRepo.updateCustomer(any()));
      verify(() => mockCustomerRepo.createCustomer(any())).called(1);
    });

    test('should update existing customer when strategy is DuplicateStrategy.update', () async {
      const sheetData = ExcelParsedSheetData(
        rows: [
          RawParsedCustomerRow(
            rowNumber: 2,
            nationalId: '29501011234567',
            fullName: 'Ahmed Hassan Updated',
            phoneNumbers: ['01299887766'],
            address: 'New Address',
            isValid: true,
          ),
        ],
        malformedErrors: [],
      );

      when(() => mockDatasource.parseSpreadsheetFile('C:/test.xlsx'))
          .thenAnswer((_) async => sheetData);

      when(() => mockCustomerRepo.getCustomerByNationalId('29501011234567'))
          .thenAnswer((_) async => Right(existingCustomer));

      when(() => mockCustomerRepo.updateCustomer(any()))
          .thenAnswer((invocation) async => Right(invocation.positionalArguments.first as Customer));

      final result = await repository.importCustomersFromFile(
        filePath: 'C:/test.xlsx',
        strategy: DuplicateStrategy.update,
      );

      expect(result.isRight(), isTrue);
      result.fold(
        (f) => fail('Expected Right'),
        (report) {
          expect(report.totalRows, 1);
          expect(report.importedCount, 0);
          expect(report.updatedCount, 1);
          expect(report.duplicateCount, 0);
          expect(report.parsedRows[0].status, ExcelRowStatus.updated);
        },
      );

      verify(() => mockCustomerRepo.updateCustomer(any())).called(1);
      verifyNever(() => mockCustomerRepo.createCustomer(any()));
    });
  });
}
