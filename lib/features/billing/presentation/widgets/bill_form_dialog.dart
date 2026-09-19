import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../../customer/presentation/cubit/customer_list_cubit.dart';
import '../../../customer/presentation/cubit/customer_list_state.dart';
import '../../domain/entities/bill.dart';
import '../cubit/billing_cubit.dart';

class BillFormDialog extends StatefulWidget {
  final Bill? bill;
  final String? defaultCustomerId;

  const BillFormDialog({
    super.key,
    this.bill,
    this.defaultCustomerId,
  });

  static Future<void> show(
    BuildContext context, {
    Bill? bill,
    String? defaultCustomerId,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => BillFormDialog(
        bill: bill,
        defaultCustomerId: defaultCustomerId,
      ),
    );
  }

  @override
  State<BillFormDialog> createState() => _BillFormDialogState();
}

class _BillFormDialogState extends State<BillFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _descCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _paidCtrl;

  String? _selectedCustomerId;
  late BillStatus _selectedStatus;
  late DateTime _issueDate;
  late DateTime _dueDate;
  bool get _isEditing => widget.bill != null;

  @override
  void initState() {
    super.initState();
    final b = widget.bill;
    _descCtrl = TextEditingController(text: b?.description ?? '');
    _amountCtrl = TextEditingController(text: b != null ? b.amount.toStringAsFixed(2) : '');
    _paidCtrl = TextEditingController(text: b != null ? b.paidAmount.toStringAsFixed(2) : '0.00');
    _selectedCustomerId = b?.customerId ?? widget.defaultCustomerId;
    _selectedStatus = b?.status ?? BillStatus.unpaid;
    _issueDate = b?.issuedAt ?? DateTime.now();
    _dueDate = b?.dueDate ?? DateTime.now().add(const Duration(days: 30));
  }

  @override
  void dispose() {
    _descCtrl.dispose();
    _amountCtrl.dispose();
    _paidCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: _issueDate,
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _dueDate = picked);
    }
  }

  void _onAmountOrPaidChanged() {
    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
    final paid = double.tryParse(_paidCtrl.text.trim()) ?? 0.0;
    if (amount > 0) {
      if (paid >= amount) {
        setState(() => _selectedStatus = BillStatus.paid);
      } else if (paid > 0) {
        setState(() => _selectedStatus = BillStatus.partial);
      } else {
        setState(() => _selectedStatus = BillStatus.unpaid);
      }
    }
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomerId == null || _selectedCustomerId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer account.')),
      );
      return;
    }

    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
    final paid = double.tryParse(_paidCtrl.text.trim()) ?? 0.0;
    final desc = _descCtrl.text.trim();
    final billingCubit = context.read<BillingCubit>();

    if (_isEditing) {
      final updated = widget.bill!.copyWith(
        customerId: _selectedCustomerId,
        amount: amount,
        paidAmount: paid,
        status: _selectedStatus,
        dueDate: _dueDate,
        description: desc,
      );
      billingCubit.updateBill(updated);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Bill #${widget.bill!.id} updated successfully.')),
      );
    } else {
      final newBill = Bill(
        id: 'bill_${DateTime.now().millisecondsSinceEpoch}',
        customerId: _selectedCustomerId!,
        amount: amount,
        paidAmount: paid,
        status: _selectedStatus,
        dueDate: _dueDate,
        issuedAt: _issueDate,
        description: desc,
      );
      billingCubit.recordBill(newBill);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New invoice/bill recorded successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _isEditing ? Icons.edit_note : Icons.receipt_long,
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(width: 10),
          Text(
            _isEditing ? 'Edit Invoice / Bill' : 'Record Invoice / Bill',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer selection
                BlocBuilder<CustomerListCubit, CustomerListState>(
                  builder: (context, state) {
                    final List<Customer> customers = state is CustomerListLoaded
                        ? state.allCustomers
                        : [];

                    if (_selectedCustomerId == null && customers.isNotEmpty) {
                      _selectedCustomerId = customers.first.id;
                    }

                    return DropdownButtonFormField<String>(
                      value: _selectedCustomerId,
                      decoration: const InputDecoration(
                        labelText: 'Customer Account *',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      items: customers.map((c) {
                        return DropdownMenuItem(
                          value: c.id,
                          child: Text('${c.fullName} (${c.nationalId})'),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedCustomerId = val),
                      validator: (val) => val == null || val.isEmpty ? 'Select customer' : null,
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Description
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Invoice Description / Service Item *',
                    hintText: 'e.g., Q3 Cloud POS Subscription & Hardware Setup',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter description' : null,
                ),
                const SizedBox(height: 16),

                // Total Amount & Paid Amount row
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Total Bill (EGP) *',
                          prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                        ),
                        onChanged: (_) => _onAmountOrPaidChanged(),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Enter amount';
                          final p = double.tryParse(val.trim());
                          if (p == null || p <= 0) return 'Invalid amount';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextFormField(
                        controller: _paidCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Paid Amount (EGP) *',
                          prefixIcon: Icon(Icons.price_check_outlined),
                        ),
                        onChanged: (_) => _onAmountOrPaidChanged(),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Enter paid amount';
                          final p = double.tryParse(val.trim());
                          if (p == null || p < 0) return 'Invalid amount';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Status & Due Date row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<BillStatus>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Payment Status',
                          prefixIcon: Icon(Icons.verified_outlined),
                        ),
                        items: BillStatus.values.map((s) {
                          return DropdownMenuItem(
                            value: s,
                            child: Text(s.displayName),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedStatus = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 4,
                      child: InkWell(
                        onTap: _pickDueDate,
                        borderRadius: BorderRadius.circular(8),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Due Date',
                            prefixIcon: Icon(Icons.event_available_outlined),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_dueDate.year}-${_dueDate.month.toString().padLeft(2, '0')}-${_dueDate.day.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: Text(_isEditing ? 'Save Changes' : 'Record Bill'),
        ),
      ],
    );
  }
}
