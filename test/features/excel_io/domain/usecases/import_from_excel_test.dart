import 'package:flutter_test/flutter_test.dart';
import 'package:fpdart/fpdart.dart';
import 'package:mocktail/mocktail.dart';

import 'package:crm_destop_sys/core/error/failures.dart';
import 'package:crm_destop_sys/features/excel_io/domain/entities/duplicate_strategy.dart';
import 'package:crm_destop_sys/features/excel_io/domain/entities/excel_import_report.dart';
import 'package:crm_destop_sys/features/excel_io/domain/repositories/excel_io_repository.dart';
import 'package:crm_destop_sys/features/excel_io/domain/usecases/import_from_excel.dart';

class MockExcelIoRepository extends Mock implements ExcelIoRepository {}

void main() {
  late ImportFromExcel useCase;
  late MockExcelIoRepository mockRepository;

  setUp(() {
    mockRepository = MockExcelIoRepository();
    useCase = ImportFromExcel(mockRepository);
  });

  const testReport = ExcelImportReport(
    totalRows: 5,
    importedCount: 3,
    updatedCount: 0,
    duplicateNationalIds: ['29501011234567'],
    malformedRowErrors: ['Row 4: National ID must be 14 digits.'],
    parsedRows: [],
  );

  test('should call importCustomersFromFile when filePath is provided', () async {
    when(() => mockRepository.importCustomersFromFile(
          filePath: 'C:/test/file.xlsx',
          strategy: DuplicateStrategy.skip,
        )).thenAnswer((_) async => const Right(testReport));

    final result = await useCase(const ImportParams(
      filePath: 'C:/test/file.xlsx',
      strategy: DuplicateStrategy.skip,
    ));

    expect(result, const Right(testReport));
    verify(() => mockRepository.importCustomersFromFile(
          filePath: 'C:/test/file.xlsx',
          strategy: DuplicateStrategy.skip,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should call importCustomersFromBytes when bytes are provided without filePath', () async {
    final bytes = [1, 2, 3, 4];
    when(() => mockRepository.importCustomersFromBytes(
          bytes: bytes,
          strategy: DuplicateStrategy.update,
        )).thenAnswer((_) async => const Right(testReport));

    final result = await useCase(ImportParams(
      bytes: bytes,
      strategy: DuplicateStrategy.update,
    ));

    expect(result, const Right(testReport));
    verify(() => mockRepository.importCustomersFromBytes(
          bytes: bytes,
          strategy: DuplicateStrategy.update,
        )).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should return ValidationFailure when neither filePath nor bytes are provided', () async {
    final result = await useCase(const ImportParams());

    expect(result.isLeft(), isTrue);
    result.fold(
      (f) => expect(f, isA<ValidationFailure>()),
      (_) => fail('Expected Left but got Right'),
    );
    verifyZeroInteractions(mockRepository);
  });
}
