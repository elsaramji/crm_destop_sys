import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/duplicate_strategy.dart';
import '../entities/excel_import_report.dart';
import '../repositories/excel_io_repository.dart';

class ImportParams extends Equatable {
  final String? filePath;
  final List<int>? bytes;
  final DuplicateStrategy strategy;

  const ImportParams({
    this.filePath,
    this.bytes,
    this.strategy = DuplicateStrategy.skip,
  });

  @override
  List<Object?> get props => [filePath, bytes, strategy];
}

class ImportFromExcel implements UseCase<ExcelImportReport, ImportParams> {
  final ExcelIoRepository repository;

  ImportFromExcel(this.repository);

  @override
  Future<Either<Failure, ExcelImportReport>> call(ImportParams params) {
    if (params.filePath != null && params.filePath!.isNotEmpty) {
      return repository.importCustomersFromFile(
        filePath: params.filePath!,
        strategy: params.strategy,
      );
    } else if (params.bytes != null && params.bytes!.isNotEmpty) {
      return repository.importCustomersFromBytes(
        bytes: params.bytes!,
        strategy: params.strategy,
      );
    } else {
      return Future.value(
        const Left(ValidationFailure('No Excel file path or bytes provided for import.')),
      );
    }
  }
}
