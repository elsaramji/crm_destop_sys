import 'package:equatable/equatable.dart';
import 'excel_parsed_row.dart';

class ExcelImportReport extends Equatable {
  final int totalRows;
  final int importedCount;
  final int updatedCount;
  final List<String> duplicateNationalIds;
  final List<String> malformedRowErrors;
  final List<ExcelParsedRow> parsedRows;

  const ExcelImportReport({
    required this.totalRows,
    required this.importedCount,
    required this.updatedCount,
    required this.duplicateNationalIds,
    required this.malformedRowErrors,
    required this.parsedRows,
  });

  int get duplicateCount => duplicateNationalIds.length;
  int get malformedCount => malformedRowErrors.length;
  int get validProcessedCount => importedCount + updatedCount;

  @override
  List<Object?> get props => [
        totalRows,
        importedCount,
        updatedCount,
        duplicateNationalIds,
        malformedRowErrors,
        parsedRows,
      ];
}
