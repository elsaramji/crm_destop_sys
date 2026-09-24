import 'package:equatable/equatable.dart';
import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/excel_export_result.dart';
import '../repositories/excel_io_repository.dart';

class ExportParams extends Equatable {
  final String? targetDirectory;

  const ExportParams({this.targetDirectory});

  @override
  List<Object?> get props => [targetDirectory];
}

class ExportToExcel implements UseCase<ExcelExportResult, ExportParams> {
  final ExcelIoRepository repository;

  ExportToExcel(this.repository);

  @override
  Future<Either<Failure, ExcelExportResult>> call(ExportParams params) {
    return repository.exportAllData(targetDirectory: params.targetDirectory);
  }
}
