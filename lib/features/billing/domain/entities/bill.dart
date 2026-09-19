import 'package:equatable/equatable.dart';

enum BillStatus {
  paid('Paid'),
  unpaid('Unpaid'),
  partial('Partial');

  final String displayName;
  const BillStatus(this.displayName);

  static BillStatus fromString(String value) {
    return BillStatus.values.firstWhere(
      (e) => e.displayName.toLowerCase() == value.toLowerCase() || e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => BillStatus.unpaid,
    );
  }
}

class Bill extends Equatable {
  final String id;
  final String customerId;
  final double amount;
  final double paidAmount;
  final BillStatus status;
  final DateTime dueDate;
  final DateTime issuedAt;
  final String? description;

  const Bill({
    required this.id,
    required this.customerId,
    required this.amount,
    this.paidAmount = 0.0,
    required this.status,
    required this.dueDate,
    required this.issuedAt,
    this.description,
  });

  double get remainingAmount => amount - paidAmount;

  Bill copyWith({
    String? id,
    String? customerId,
    double? amount,
    double? paidAmount,
    BillStatus? status,
    DateTime? dueDate,
    DateTime? issuedAt,
    String? description,
  }) {
    return Bill(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      amount: amount ?? this.amount,
      paidAmount: paidAmount ?? this.paidAmount,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      issuedAt: issuedAt ?? this.issuedAt,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        amount,
        paidAmount,
        status,
        dueDate,
        issuedAt,
        description,
      ];
}
