import 'package:equatable/equatable.dart';

class ExcelImportReport extends Equatable {
  final int totalRows;
  final int validRowsCount;
  final List<String> duplicateNationalIds;
  final List<String> malformedRowErrors;
  final List<Map<String, String>> importedSampleRows;

  const ExcelImportReport({
    required this.totalRows,
    required this.validRowsCount,
    required this.duplicateNationalIds,
    required this.malformedRowErrors,
    required this.importedSampleRows,
  });

  @override
  List<Object?> get props => [
        totalRows,
        validRowsCount,
        duplicateNationalIds,
        malformedRowErrors,
        importedSampleRows,
      ];
}

abstract class ExcelIoState extends Equatable {
  const ExcelIoState();

  @override
  List<Object?> get props => [];
}

class ExcelIoInitial extends ExcelIoState {
  const ExcelIoInitial();
}

class ExcelIoProcessing extends ExcelIoState {
  final String operationMessage;
  const ExcelIoProcessing(this.operationMessage);

  @override
  List<Object?> get props => [operationMessage];
}

class ExcelExportSuccess extends ExcelIoState {
  final String filename;
  final int customersCount;
  final int servicesCount;
  final int activitiesCount;
  final int ordersCount;
  final int billsCount;
  final DateTime exportedAt;

  const ExcelExportSuccess({
    required this.filename,
    required this.customersCount,
    required this.servicesCount,
    required this.activitiesCount,
    required this.ordersCount,
    required this.billsCount,
    required this.exportedAt,
  });

  @override
  List<Object?> get props => [
        filename,
        customersCount,
        servicesCount,
        activitiesCount,
        ordersCount,
        billsCount,
        exportedAt,
      ];
}

class ExcelImportSuccess extends ExcelIoState {
  final ExcelImportReport report;
  const ExcelImportSuccess(this.report);

  @override
  List<Object?> get props => [report];
}

class ExcelIoError extends ExcelIoState {
  final String message;
  const ExcelIoError(this.message);

  @override
  List<Object?> get props => [message];
}
