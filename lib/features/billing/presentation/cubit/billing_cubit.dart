import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/bill.dart';
import '../../domain/usecases/delete_bill.dart';
import '../../domain/usecases/get_all_bills.dart';
import '../../domain/usecases/get_bills_by_customer.dart';
import '../../domain/usecases/record_bill.dart';
import '../../domain/usecases/update_bill.dart';
import '../../domain/usecases/update_bill_status.dart';
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
  final GetAllBills _getAllBills;
  final GetBillsByCustomer _getBillsByCustomer;
  final RecordBill _recordBill;
  final UpdateBill _updateBill;
  final UpdateBillStatus _updateBillStatus;
  final DeleteBill _deleteBill;

  BillingCubit({
    required GetAllBills getAllBills,
    required GetBillsByCustomer getBillsByCustomer,
    required RecordBill recordBill,
    required UpdateBill updateBill,
    required UpdateBillStatus updateBillStatus,
    required DeleteBill deleteBill,
  })  : _getAllBills = getAllBills,
        _getBillsByCustomer = getBillsByCustomer,
        _recordBill = recordBill,
        _updateBill = updateBill,
        _updateBillStatus = updateBillStatus,
        _deleteBill = deleteBill,
        super(const BillingLoading()) {
    loadBills();
  }

  Future<void> loadBills() async {
    emit(const BillingLoading());
    final result = await _getAllBills(const NoParams());
    result.fold<void>(
      (_) => emit(const BillingLoaded(allBills: [])),
      (bills) => emit(BillingLoaded(allBills: bills)),
    );
  }

  Future<void> loadBillsForCustomer(String customerId) async {
    emit(const BillingLoading());
    final result = await _getBillsByCustomer(customerId);
    result.fold<void>(
      (_) => emit(const BillingLoaded(allBills: [])),
      (bills) => emit(BillingLoaded(allBills: bills)),
    );
  }

  Future<void> recordBill(Bill bill) async {
    final result = await _recordBill(bill);
    result.fold<void>(
      (_) {},
      (saved) {
        if (state is BillingLoaded) {
          final current = state as BillingLoaded;
          final List<Bill> updated = [saved, ...current.allBills];
          emit(current.copyWith(allBills: updated));
        } else {
          loadBills();
        }
      },
    );
  }

  Future<void> updateBill(Bill bill) async {
    final result = await _updateBill(bill);
    result.fold<void>(
      (_) {},
      (saved) {
        if (state is BillingLoaded) {
          final current = state as BillingLoaded;
          final List<Bill> updated = current.allBills
              .map((b) => b.id == saved.id ? saved : b)
              .toList();
          emit(current.copyWith(allBills: updated));
        } else {
          loadBills();
        }
      },
    );
  }

  Future<void> deleteBill(String billId) async {
    final result = await _deleteBill(billId);
    result.fold<void>(
      (_) {},
      (_) {
        if (state is BillingLoaded) {
          final current = state as BillingLoaded;
          final List<Bill> updated =
              current.allBills.where((b) => b.id != billId).toList();
          emit(current.copyWith(allBills: updated));
        }
      },
    );
  }

  Future<void> updateBillStatus(
    String billId,
    BillStatus newStatus,
    double paidAmount,
  ) async {
    final result = await _updateBillStatus(
      UpdateBillStatusParams(
        billId: billId,
        status: newStatus,
        paidAmount: paidAmount,
      ),
    );
    result.fold<void>(
      (_) {},
      (_) {
        if (state is BillingLoaded) {
          final current = state as BillingLoaded;
          final List<Bill> updated = current.allBills.map((b) {
            if (b.id == billId) {
              return b.copyWith(status: newStatus, paidAmount: paidAmount);
            }
            return b;
          }).toList();
          emit(current.copyWith(allBills: updated));
        } else {
          loadBills();
        }
      },
    );
  }

  void filterByStatus(BillStatus? status) {
    if (state is! BillingLoaded) return;
    final current = state as BillingLoaded;
    emit(BillingLoaded(
      allBills: current.allBills,
      statusFilter: status,
    ));
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
