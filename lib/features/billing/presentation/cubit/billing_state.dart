import 'package:equatable/equatable.dart';
import '../../domain/entities/bill.dart';

abstract class BillingState extends Equatable {
  const BillingState();

  @override
  List<Object?> get props => [];
}

class BillingLoading extends BillingState {
  const BillingLoading();
}

class BillingLoaded extends BillingState {
  final List<Bill> allBills;
  final BillStatus? statusFilter;

  const BillingLoaded({
    required this.allBills,
    this.statusFilter,
  });

  List<Bill> get filteredBills {
    if (statusFilter == null) return allBills;
    return allBills.where((b) => b.status == statusFilter).toList();
  }

  double get totalBilled => allBills.fold(0.0, (sum, b) => sum + b.amount);
  double get totalCollected => allBills.fold(0.0, (sum, b) => sum + b.paidAmount);
  double get totalReceivables => totalBilled - totalCollected;

  BillingLoaded copyWith({
    List<Bill>? allBills,
    BillStatus? statusFilter,
    bool clearStatusFilter = false,
  }) {
    return BillingLoaded(
      allBills: allBills ?? this.allBills,
      statusFilter: clearStatusFilter ? null : (statusFilter ?? this.statusFilter),
    );
  }

  @override
  List<Object?> get props => [allBills, statusFilter];
}
