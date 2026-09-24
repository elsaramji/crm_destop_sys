import 'package:equatable/equatable.dart';

import '../../domain/entities/excel_export_result.dart';
import '../../domain/entities/excel_import_report.dart';

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
  final ExcelExportResult result;

  const ExcelExportSuccess(this.result);

  String get filename => result.fileName;
  String get filePath => result.filePath;
  int get customersCount => result.customersCount;
  int get servicesCount => result.servicesCount;
  int get activitiesCount => result.activitiesCount;
  int get ordersCount => result.ordersCount;
  int get billsCount => result.billsCount;
  DateTime get exportedAt => result.exportedAt;

  @override
  List<Object?> get props => [result];
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
