import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/mock/mock_data.dart';
import '../../domain/entities/bill.dart';
import 'billing_state.dart';

class CustomerBalance {
  final double totalBilled;
  final double totalPaid;
  final double outstandingBalance;

  const CustomerBalance({
    required this.totalBilled,
    required this.totalPaid,
    required this.outstandingBalance,
  });
}

class BillingCubit extends Cubit<BillingState> {
  BillingCubit() : super(const BillingLoading()) {
    loadBills();
  }

  void loadBills() {
    emit(BillingLoaded(
      allBills: List<Bill>.from(MockData.initialBills),
    ));
  }

  void recordBill(Bill bill) {
    if (state is! BillingLoaded) return;
    final current = state as BillingLoaded;
    final updated = [bill, ...current.allBills];
    emit(current.copyWith(allBills: updated));
  }

  void updateBill(Bill bill) {
    if (state is! BillingLoaded) return;
    final current = state as BillingLoaded;
    final updated = current.allBills.map((b) => b.id == bill.id ? bill : b).toList();
    emit(current.copyWith(allBills: updated));
  }

  void deleteBill(String billId) {
    if (state is! BillingLoaded) return;
    final current = state as BillingLoaded;
    final updated = current.allBills.where((b) => b.id != billId).toList();
    emit(current.copyWith(allBills: updated));
  }

  void updateBillStatus(String billId, BillStatus newStatus, double paidAmount) {
    if (state is! BillingLoaded) return;
    final current = state as BillingLoaded;
    final updated = current.allBills.map((b) {
      if (b.id == billId) {
        return b.copyWith(
          status: newStatus,
          paidAmount: paidAmount,
        );
      }
      return b;
    }).toList();
    emit(current.copyWith(allBills: updated));
  }

  void filterByStatus(BillStatus? status) {
    if (state is! BillingLoaded) return;
    final current = state as BillingLoaded;
    emit(current.copyWith(statusFilter: status));
  }

  List<Bill> getBillsForCustomer(String customerId) {
    if (state is! BillingLoaded) return [];
    final current = state as BillingLoaded;
    return current.allBills.where((b) => b.customerId == customerId).toList();
  }

  CustomerBalance getCustomerBalanceSummary(String customerId) {
    final customerBills = getBillsForCustomer(customerId);
    final totalBilled = customerBills.fold(0.0, (sum, b) => sum + b.amount);
    final totalPaid = customerBills.fold(0.0, (sum, b) => sum + b.paidAmount);
    return CustomerBalance(
      totalBilled: totalBilled,
      totalPaid: totalPaid,
      outstandingBalance: totalBilled - totalPaid,
    );
  }
}
