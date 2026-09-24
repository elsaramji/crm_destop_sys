import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crm_destop_sys/core/error/failures.dart';
import 'package:crm_destop_sys/features/excel_io/domain/entities/duplicate_strategy.dart';
import 'package:crm_destop_sys/features/excel_io/domain/entities/excel_export_result.dart';
import 'package:crm_destop_sys/features/excel_io/domain/entities/excel_import_report.dart';
import 'package:crm_destop_sys/features/excel_io/domain/usecases/export_to_excel.dart';
import 'package:crm_destop_sys/features/excel_io/domain/usecases/import_from_excel.dart';
import 'package:crm_destop_sys/features/excel_io/presentation/cubit/excel_io_cubit.dart';
import 'package:crm_destop_sys/features/excel_io/presentation/cubit/excel_io_state.dart';

class MockExportToExcel extends Mock implements ExportToExcel {}
class MockImportFromExcel extends Mock implements ImportFromExcel {}

void main() {
  late MockExportToExcel mockExportToExcel;
  late MockImportFromExcel mockImportFromExcel;
  late ExcelIoCubit cubit;

  setUp(() {
    mockExportToExcel = MockExportToExcel();
    mockImportFromExcel = MockImportFromExcel();
    cubit = ExcelIoCubit(
      exportToExcel: mockExportToExcel,
      importFromExcel: mockImportFromExcel,
    );

    registerFallbackValue(const ExportParams());
    registerFallbackValue(const ImportParams());
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state should be ExcelIoInitial', () {
    expect(cubit.state, const ExcelIoInitial());
  });

  final testExportResult = ExcelExportResult(
    filePath: 'C:/Exports/CRM_Export.xlsx',
    fileName: 'CRM_Export.xlsx',
    customersCount: 5,
    servicesCount: 3,
    activitiesCount: 2,
    ordersCount: 1,
    billsCount: 1,
    exportedAt: DateTime(2026, 9, 24),
  );

  const testImportReport = ExcelImportReport(
    totalRows: 4,
    importedCount: 2,
    updatedCount: 0,
    duplicateNationalIds: ['29501011234567'],
    malformedRowErrors: ['Row 4: Invalid phone'],
    parsedRows: [],
  );

  blocTest<ExcelIoCubit, ExcelIoState>(
    'emits [ExcelIoProcessing, ExcelExportSuccess] when exportData succeeds',
    build: () {
      when(() => mockExportToExcel(any()))
          .thenAnswer((_) async => Right(testExportResult));
      return cubit;
    },
    act: (cubit) => cubit.exportData(targetDirectory: 'C:/Exports'),
    expect: () => [
      const ExcelIoProcessing('Compiling database records and generating 5-sheet workbook...'),
      ExcelExportSuccess(testExportResult),
    ],
    verify: (_) {
      verify(() => mockExportToExcel(const ExportParams(targetDirectory: 'C:/Exports'))).called(1);
    },
  );

  blocTest<ExcelIoCubit, ExcelIoState>(
    'emits [ExcelIoProcessing, ExcelIoError] when exportData fails',
    build: () {
      when(() => mockExportToExcel(any()))
          .thenAnswer((_) async => const Left(ExcelFailure('Failed to encode workbook')));
      return cubit;
    },
    act: (cubit) => cubit.exportData(),
    expect: () => [
      const ExcelIoProcessing('Compiling database records and generating 5-sheet workbook...'),
      const ExcelIoError('Failed to encode workbook'),
    ],
  );

  blocTest<ExcelIoCubit, ExcelIoState>(
    'emits [ExcelIoProcessing, ExcelImportSuccess] when importFromFile succeeds',
    build: () {
      when(() => mockImportFromExcel(any()))
          .thenAnswer((_) async => const Right(testImportReport));
      return cubit;
    },
    act: (cubit) => cubit.importFromFile(
      filePath: 'C:/test.xlsx',
      strategy: DuplicateStrategy.skip,
    ),
    expect: () => [
      const ExcelIoProcessing('Reading .xlsx spreadsheet, validating Egyptian National IDs & mobile numbers...'),
      const ExcelImportSuccess(testImportReport),
    ],
    verify: (_) {
      verify(() => mockImportFromExcel(const ImportParams(
            filePath: 'C:/test.xlsx',
            strategy: DuplicateStrategy.skip,
          ))).called(1);
    },
  );

  blocTest<ExcelIoCubit, ExcelIoState>(
    'emits [ExcelIoProcessing, ExcelIoError] when importFromFile fails',
    build: () {
      when(() => mockImportFromExcel(any()))
          .thenAnswer((_) async => const Left(ExcelFailure('File not found')));
      return cubit;
    },
    act: (cubit) => cubit.importFromFile(filePath: 'C:/non_existent.xlsx'),
    expect: () => [
      const ExcelIoProcessing('Reading .xlsx spreadsheet, validating Egyptian National IDs & mobile numbers...'),
      const ExcelIoError('File not found'),
    ],
  );

  blocTest<ExcelIoCubit, ExcelIoState>(
    'emits [ExcelIoInitial] when reset is called',
    build: () => cubit,
    act: (cubit) => cubit.reset(),
    expect: () => [
      const ExcelIoInitial(),
    ],
  );
}
