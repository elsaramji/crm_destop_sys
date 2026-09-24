import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/duplicate_strategy.dart';
import '../entities/excel_export_result.dart';
import '../entities/excel_import_report.dart';

abstract class ExcelIoRepository {
  Future<Either<Failure, ExcelExportResult>> exportAllData({String? targetDirectory});
  Future<Either<Failure, ExcelImportReport>> importCustomersFromFile({
    required String filePath,
    required DuplicateStrategy strategy,
  });
  Future<Either<Failure, ExcelImportReport>> importCustomersFromBytes({
    required List<int> bytes,
    required DuplicateStrategy strategy,
  });
}
