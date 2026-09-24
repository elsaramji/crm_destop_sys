import 'package:equatable/equatable.dart';

class ExcelExportResult extends Equatable {
  final String filePath;
  final String fileName;
  final int customersCount;
  final int servicesCount;
  final int activitiesCount;
  final int ordersCount;
  final int billsCount;
  final DateTime exportedAt;

  const ExcelExportResult({
    required this.filePath,
    required this.fileName,
    required this.customersCount,
    required this.servicesCount,
    required this.activitiesCount,
    required this.ordersCount,
    required this.billsCount,
    required this.exportedAt,
  });

  @override
  List<Object?> get props => [
        filePath,
        fileName,
        customersCount,
        servicesCount,
        activitiesCount,
        ordersCount,
        billsCount,
        exportedAt,
      ];
}
