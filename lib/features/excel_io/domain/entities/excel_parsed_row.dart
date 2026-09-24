import 'package:equatable/equatable.dart';

enum ExcelRowStatus {
  imported,
  updated,
  duplicateSkipped,
  malformed,
}

class ExcelParsedRow extends Equatable {
  final int rowNumber;
  final String nationalId;
  final String fullName;
  final List<String> phoneNumbers;
  final String? address;
  final String? email;
  final ExcelRowStatus status;
  final String? errorMessage;

  const ExcelParsedRow({
    required this.rowNumber,
    required this.nationalId,
    required this.fullName,
    required this.phoneNumbers,
    this.address,
    this.email,
    required this.status,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
        rowNumber,
        nationalId,
        fullName,
        phoneNumbers,
        address,
        email,
        status,
        errorMessage,
      ];
}
