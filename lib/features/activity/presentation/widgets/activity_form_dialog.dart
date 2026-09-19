import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../../customer/presentation/cubit/customer_list_cubit.dart';
import '../../../customer/presentation/cubit/customer_list_state.dart';
import '../../domain/entities/activity.dart';
import '../cubit/activity_cubit.dart';

class ActivityFormDialog extends StatefulWidget {
  final Activity? activity;
  final String? defaultCustomerId;

  const ActivityFormDialog({
    super.key,
    this.activity,
    this.defaultCustomerId,
  });

  static Future<void> show(
    BuildContext context, {
    Activity? activity,
    String? defaultCustomerId,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => ActivityFormDialog(
        activity: activity,
        defaultCustomerId: defaultCustomerId,
      ),
    );
  }

  @override
  State<ActivityFormDialog> createState() => _ActivityFormDialogState();
}

class _ActivityFormDialogState extends State<ActivityFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _noteCtrl;

  String? _selectedCustomerId;
  late ActivityType _selectedType;
  late DateTime _selectedDateTime;
  bool get _isEditing => widget.activity != null;

  @override
  void initState() {
    super.initState();
    final a = widget.activity;
    _noteCtrl = TextEditingController(text: a?.note ?? '');
    _selectedCustomerId = a?.customerId ?? widget.defaultCustomerId;
    _selectedType = a?.type ?? ActivityType.call;
    _selectedDateTime = a?.timestamp ?? DateTime.now();
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (date == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomerId == null || _selectedCustomerId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer account.')),
      );
      return;
    }

    final note = _noteCtrl.text.trim();
    final activityCubit = context.read<ActivityCubit>();

    if (_isEditing) {
      final updated = widget.activity!.copyWith(
        customerId: _selectedCustomerId,
        type: _selectedType,
        note: note,
        timestamp: _selectedDateTime,
      );
      activityCubit.updateActivity(updated);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity updated successfully.')),
      );
    } else {
      final newActivity = Activity(
        id: 'act_${DateTime.now().millisecondsSinceEpoch}',
        customerId: _selectedCustomerId!,
        type: _selectedType,
        note: note,
        timestamp: _selectedDateTime,
      );
      activityCubit.logActivity(newActivity);
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Activity logged successfully.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _isEditing ? Icons.edit_note : Icons.add_comment,
            color: AppTheme.primaryBlue,
          ),
          const SizedBox(width: 10),
          Text(
            _isEditing ? 'Edit Activity Record' : 'Log Interaction Activity',
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
                // Customer selector
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

                // Activity Type & Date Time row
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: DropdownButtonFormField<ActivityType>(
                        value: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Activity Category / Type *',
                          prefixIcon: Icon(Icons.category_outlined),
                        ),
                        items: ActivityType.values.map((t) {
                          return DropdownMenuItem(
                            value: t,
                            child: Text(t.displayName),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedType = val);
                        },
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      flex: 4,
                      child: InkWell(
                        onTap: _pickDateTime,
                        borderRadius: BorderRadius.circular(8),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Date & Time',
                            prefixIcon: Icon(Icons.access_time),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_selectedDateTime.year}-${_selectedDateTime.month.toString().padLeft(2, '0')}-${_selectedDateTime.day.toString().padLeft(2, '0')} ${_selectedDateTime.hour.toString().padLeft(2, '0')}:${_selectedDateTime.minute.toString().padLeft(2, '0')}',
                                style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                              ),
                              const Icon(Icons.arrow_drop_down),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Note
                TextFormField(
                  controller: _noteCtrl,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Interaction Notes & Details *',
                    hintText: 'Summary of the phone call, site visit findings, or complaint resolution...',
                    prefixIcon: Icon(Icons.notes_outlined),
                    alignLabelWithHint: true,
                  ),
                  validator: (val) => val == null || val.trim().isEmpty ? 'Enter interaction notes' : null,
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
          child: Text(_isEditing ? 'Save Changes' : 'Log Activity'),
        ),
      ],
    );
  }
}
