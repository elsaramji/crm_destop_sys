import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crm_destop_sys/core/error/failures.dart';
import 'package:crm_destop_sys/features/excel_io/domain/entities/excel_export_result.dart';
import 'package:crm_destop_sys/features/excel_io/domain/repositories/excel_io_repository.dart';
import 'package:crm_destop_sys/features/excel_io/domain/usecases/export_to_excel.dart';

class MockExcelIoRepository extends Mock implements ExcelIoRepository {}

void main() {
  late ExportToExcel useCase;
  late MockExcelIoRepository mockRepository;

  setUp(() {
    mockRepository = MockExcelIoRepository();
    useCase = ExportToExcel(mockRepository);
  });

  final testResult = ExcelExportResult(
    filePath: 'C:/Exports/CRM_Export.xlsx',
    fileName: 'CRM_Export.xlsx',
    customersCount: 10,
    servicesCount: 5,
    activitiesCount: 8,
    ordersCount: 4,
    billsCount: 3,
    exportedAt: DateTime(2026, 9, 24),
  );

  test('should return ExcelExportResult from the repository on success', () async {
    when(() => mockRepository.exportAllData(targetDirectory: any(named: 'targetDirectory')))
        .thenAnswer((_) async => Right(testResult));

    final result = await useCase(const ExportParams(targetDirectory: 'C:/Exports'));

    expect(result, Right(testResult));
    verify(() => mockRepository.exportAllData(targetDirectory: 'C:/Exports')).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ExcelFailure when export fails', () async {
    const failure = ExcelFailure('Disk write permission denied');
    when(() => mockRepository.exportAllData(targetDirectory: any(named: 'targetDirectory')))
        .thenAnswer((_) async => const Left(failure));

    final result = await useCase(const ExportParams());

    expect(result, const Left(failure));
    verify(() => mockRepository.exportAllData(targetDirectory: null)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
