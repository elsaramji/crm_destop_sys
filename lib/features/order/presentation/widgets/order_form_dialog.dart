import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../../customer/presentation/cubit/customer_list_cubit.dart';
import '../../../customer/presentation/cubit/customer_list_state.dart';
import '../../../customer/presentation/widgets/customer_id_lookup_field.dart';
import '../../domain/entities/order.dart';
import '../cubit/order_cubit.dart';

class OrderFormDialog extends StatefulWidget {
  final Order? order;
  final String? defaultCustomerId;

  const OrderFormDialog({
    super.key,
    this.order,
    this.defaultCustomerId,
  });

  static Future<void> show(
    BuildContext context, {
    Order? order,
    String? defaultCustomerId,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => OrderFormDialog(
        order: order,
        defaultCustomerId: defaultCustomerId,
      ),
    );
  }

  @override
  State<OrderFormDialog> createState() => _OrderFormDialogState();
}

class _OrderFormDialogState extends State<OrderFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _itemsCtrl;
  late final TextEditingController _amountCtrl;

  String? _selectedCustomerId;
  late OrderStatus _selectedStatus;
  late DateTime _selectedDate;
  bool get _isEditing => widget.order != null;

  @override
  void initState() {
    super.initState();
    final o = widget.order;
    _itemsCtrl = TextEditingController(text: o != null ? o.items.join(', ') : '');
    _amountCtrl = TextEditingController(text: o != null ? o.totalAmount.toStringAsFixed(2) : '');
    _selectedCustomerId = o?.customerId ?? widget.defaultCustomerId;
    _selectedStatus = o?.status ?? OrderStatus.pending;
    _selectedDate = o?.createdAt ?? DateTime.now();
  }

  @override
  void dispose() {
    _itemsCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
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

    final items = _itemsCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter at least one ordered item.')),
      );
      return;
    }

    final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0.0;
    final orderCubit = context.read<OrderCubit>();

    if (_isEditing) {
      final updated = widget.order!.copyWith(
        customerId: _selectedCustomerId,
        items: items,
        status: _selectedStatus,
        totalAmount: amount,
        updatedAt: DateTime.now(),
      );
      orderCubit.updateOrder(updated);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order #${widget.order!.id} updated successfully.')),
      );
    } else {
      final newOrder = Order(
        id: 'ord_${DateTime.now().millisecondsSinceEpoch}',
        customerId: _selectedCustomerId!,
        items: items,
        status: _selectedStatus,
        totalAmount: amount,
        createdAt: _selectedDate,
        updatedAt: DateTime.now(),
      );
      orderCubit.createOrder(newOrder);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New order created successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _isEditing ? Icons.edit_note : Icons.add_shopping_cart,
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(width: 10),
          Text(
            _isEditing ? 'Edit Order' : 'Create Customer Order',
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
                // Customer ID lookup
                CustomerIdLookupField(
                  initialCustomerId: _selectedCustomerId,
                  onCustomerSelected: (customer) {
                    _selectedCustomerId = customer?.id;
                  },
                ),
                const SizedBox(height: 16),

                // Order items
                TextFormField(
                  controller: _itemsCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Ordered Items (comma-separated) *',
                    hintText: 'e.g., POS Terminal Hardware, Thermal Receipt Printer, Roll Paper',
                    prefixIcon: Icon(Icons.inventory_2_outlined),
                    alignLabelWithHint: true,
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter items' : null,
                ),
                const SizedBox(height: 16),

                // Total Amount & Status row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: _amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Total Amount (EGP) *',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
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
                      flex: 3,
                      child: DropdownButtonFormField<OrderStatus>(
                        value: _selectedStatus,
                        decoration: const InputDecoration(
                          labelText: 'Fulfillment Status',
                          prefixIcon: Icon(Icons.flag_outlined),
                        ),
                        items: OrderStatus.values.map((s) {
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
                  ],
                ),
                const SizedBox(height: 16),

                // Order Date
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(8),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Order Date',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        const Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),
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
          child: Text(_isEditing ? 'Save Changes' : 'Create Order'),
        ),
      ],
    );
  }
}
