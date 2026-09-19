import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../../customer/presentation/cubit/customer_list_cubit.dart';
import '../../../customer/presentation/cubit/customer_list_state.dart';
import '../../../customer/presentation/widgets/customer_id_lookup_field.dart';
import '../../domain/entities/service_item.dart';
import '../cubit/service_cubit.dart';

class ServiceFormDialog extends StatefulWidget {
  final ServiceItem? service;
  final String? defaultCustomerId;

  const ServiceFormDialog({
    super.key,
    this.service,
    this.defaultCustomerId,
  });

  static Future<void> show(
    BuildContext context, {
    ServiceItem? service,
    String? defaultCustomerId,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ServiceFormDialog(
        service: service,
        defaultCustomerId: defaultCustomerId,
      ),
    );
  }

  @override
  State<ServiceFormDialog> createState() => _ServiceFormDialogState();
}

class _ServiceFormDialogState extends State<ServiceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late final TextEditingController _categoryCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _notesCtrl;

  String? _selectedCustomerId;
  late DateTime _selectedDate;
  bool get _isEditing => widget.service != null;

  static const List<String> _commonCategories = [
    'Retail POS',
    'Telecom',
    'Maintenance',
    'Software',
    'Consulting',
    'Hardware',
    'Cloud Hosting',
  ];

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    _nameCtrl = TextEditingController(text: s?.name ?? '');
    _categoryCtrl = TextEditingController(text: s?.category ?? 'Maintenance');
    _priceCtrl = TextEditingController(text: s != null ? s.price.toStringAsFixed(2) : '');
    _notesCtrl = TextEditingController(text: s?.notes ?? '');
    _selectedCustomerId = s?.customerId ?? widget.defaultCustomerId;
    _selectedDate = s?.dateProvided ?? DateTime.now();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _categoryCtrl.dispose();
    _priceCtrl.dispose();
    _notesCtrl.dispose();
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

    final price = double.tryParse(_priceCtrl.text.trim()) ?? 0.0;
    final name = _nameCtrl.text.trim();
    final category = _categoryCtrl.text.trim();
    final notes = _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim();

    final serviceCubit = context.read<ServiceCubit>();

    if (_isEditing) {
      final updated = widget.service!.copyWith(
        name: name,
        category: category,
        customerId: _selectedCustomerId,
        price: price,
        dateProvided: _selectedDate,
        notes: notes,
      );
      serviceCubit.updateService(updated);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service "$name" updated successfully.')),
      );
    } else {
      final newService = ServiceItem(
        id: 'srv_${DateTime.now().millisecondsSinceEpoch}',
        customerId: _selectedCustomerId!,
        name: name,
        category: category,
        price: price,
        dateProvided: _selectedDate,
        notes: notes,
      );
      serviceCubit.addService(newService);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Service "$name" added successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _isEditing ? Icons.edit_note : Icons.add_circle_outline,
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(width: 10),
          Text(
            _isEditing ? 'Edit Service' : 'Add New Service',
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

                // Service Name
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Service Name *',
                    prefixIcon: Icon(Icons.build_outlined),
                    hintText: 'e.g., POS System Annual License',
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter service name' : null,
                ),
                const SizedBox(height: 16),

                // Category & Price row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Autocomplete<String>(
                        initialValue: TextEditingValue(text: _categoryCtrl.text),
                        optionsBuilder: (textEditingValue) {
                          if (textEditingValue.text.isEmpty) {
                            return _commonCategories;
                          }
                          return _commonCategories.where((cat) => cat
                              .toLowerCase()
                              .contains(textEditingValue.text.toLowerCase()));
                        },
                        onSelected: (val) {
                          _categoryCtrl.text = val;
                        },
                        fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                          controller.addListener(() {
                            _categoryCtrl.text = controller.text;
                          });
                          return TextFormField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: const InputDecoration(
                              labelText: 'Category *',
                              prefixIcon: Icon(Icons.category_outlined),
                            ),
                            validator: (val) => val == null || val.trim().isEmpty ? 'Category required' : null,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 2,
                      child: TextFormField(
                        controller: _priceCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Price (EGP) *',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Enter price';
                          final p = double.tryParse(val.trim());
                          if (p == null || p <= 0) return 'Invalid price';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Date Provided
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(8),
                  child: InputDecorator(
                    decoration: const InputDecoration(
                      labelText: 'Date Provided',
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
                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Notes / Scope Details',
                    prefixIcon: Icon(Icons.notes_outlined),
                    alignLabelWithHint: true,
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
          child: Text(_isEditing ? 'Save Changes' : 'Add Service'),
        ),
      ],
    );
  }
}
