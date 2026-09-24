import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/duplicate_strategy.dart';
import '../../domain/usecases/export_to_excel.dart';
import '../../domain/usecases/import_from_excel.dart';
import 'excel_io_state.dart';

class ExcelIoCubit extends Cubit<ExcelIoState> {
  final ExportToExcel exportToExcel;
  final ImportFromExcel importFromExcel;

  ExcelIoCubit({
    required this.exportToExcel,
    required this.importFromExcel,
  }) : super(const ExcelIoInitial());

  Future<void> exportData({String? targetDirectory}) async {
    emit(const ExcelIoProcessing('Compiling database records and generating 5-sheet workbook...'));
    final result = await exportToExcel(ExportParams(targetDirectory: targetDirectory));
    result.fold(
      (failure) => emit(ExcelIoError(failure.message)),
      (exportResult) => emit(ExcelExportSuccess(exportResult)),
    );
  }

  Future<void> exportAllData({String? targetDirectory, dynamic customerCubit, dynamic serviceCubit, dynamic activityCubit, dynamic orderCubit, dynamic billingCubit}) async {
    await exportData(targetDirectory: targetDirectory);
  }

  Future<void> importFromFile({
    required String filePath,
    DuplicateStrategy strategy = DuplicateStrategy.skip,
  }) async {
    emit(const ExcelIoProcessing('Reading .xlsx spreadsheet, validating Egyptian National IDs & mobile numbers...'));
    final result = await importFromExcel(ImportParams(
      filePath: filePath,
      strategy: strategy,
    ));
    result.fold(
      (failure) => emit(ExcelIoError(failure.message)),
      (report) => emit(ExcelImportSuccess(report)),
    );
  }

  Future<void> importFromBytes({
    required List<int> bytes,
    DuplicateStrategy strategy = DuplicateStrategy.skip,
  }) async {
    emit(const ExcelIoProcessing('Parsing .xlsx bytes and evaluating duplicate resolution strategy...'));
    final result = await importFromExcel(ImportParams(
      bytes: bytes,
      strategy: strategy,
    ));
    result.fold(
      (failure) => emit(ExcelIoError(failure.message)),
      (report) => emit(ExcelImportSuccess(report)),
    );
  }

  void reset() {
    emit(const ExcelIoInitial());
  }
}
