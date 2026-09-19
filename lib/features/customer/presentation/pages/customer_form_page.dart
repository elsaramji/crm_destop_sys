import 'package:crm_destop_sys/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../cubit/customer_form_cubit.dart';
import '../cubit/customer_form_state.dart';
import '../cubit/customer_list_cubit.dart';

class CustomerFormPage extends StatefulWidget {
  final String? customerId;
  const CustomerFormPage({super.key, this.customerId});

  @override
  State<CustomerFormPage> createState() => _CustomerFormPageState();
}

class _CustomerFormPageState extends State<CustomerFormPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _nationalIdController;
  late final TextEditingController _addressController;
  late final TextEditingController _emailController;
  late final TextEditingController _branchController;
  late final TextEditingController _vipTierController;

  @override
  void initState() {
    super.initState();
    final formCubit = context.read<CustomerFormCubit>();
    final listCubit = context.read<CustomerListCubit>();

    _nameController = TextEditingController();
    _nationalIdController = TextEditingController();
    _addressController = TextEditingController();
    _emailController = TextEditingController();
    _branchController = TextEditingController();
    _vipTierController = TextEditingController();

    if (widget.customerId != null) {
      final existing = listCubit.getCustomerById(widget.customerId!);
      if (existing != null) {
        formCubit.initForEdit(existing);
        _nameController.text = existing.fullName;
        _nationalIdController.text = existing.nationalId;
        _addressController.text = existing.address ?? '';
        _emailController.text = existing.email ?? '';
        _branchController.text = existing.customFields['Preferred Branch'] ?? '';
        _vipTierController.text = existing.customFields['VIP Tier'] ?? '';
      }
    } else {
      formCubit.initForCreate();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nationalIdController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _branchController.dispose();
    _vipTierController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerFormCubit, CustomerFormState>(
      listener: (context, state) {
        if (state.isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: AppTheme.successGreen,
              content: Text(state.isEdit ? 'Customer profile updated successfully' : 'Customer created successfully'),
            ),
          );
          context.go('/customers/${state.id}');
        }
      },
      builder: (context, state) {
        final formCubit = context.read<CustomerFormCubit>();
        final listCubit = context.read<CustomerListCubit>();

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.isEdit ? 'Edit Customer Profile' : 'New Customer Registration',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  state.isEdit ? 'Update identification and contact details' : 'Enter Egyptian National ID and contact details',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
          body: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Error message if validation failed
                        if (state.errorMessage != null) ...[
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEE2E2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFFCA5A5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.error_outline, color: AppTheme.dangerRed, size: 20),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    state.errorMessage!,
                                    style: const TextStyle(color: Color(0xFFB91C1C), fontWeight: FontWeight.w500),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],

                        // Full Name
                        const Text('Full Name *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _nameController,
                          onChanged: formCubit.setFullName,
                          decoration: const InputDecoration(
                            hintText: 'e.g. Ahmed Mahmoud Hassan',
                            prefixIcon: Icon(Icons.person_outline, size: 20),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // National ID (14 Digits)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Egyptian National ID *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            Text(
                              '${state.nationalId.length}/14 digits',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: state.nationalId.length == 14 ? AppTheme.successGreen : AppTheme.textMuted,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _nationalIdController,
                          maxLength: 14,
                          keyboardType: TextInputType.number,
                          onChanged: formCubit.setNationalId,
                          decoration: InputDecoration(
                            hintText: '14-digit Egyptian National ID (e.g. 29501011234567)',
                            prefixIcon: const Icon(Icons.badge_outlined, size: 20),
                            counterText: '',
                            suffixIcon: state.nationalId.length == 14
                                ? const Icon(Icons.check_circle, color: AppTheme.successGreen, size: 20)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Phone Numbers Section (1..n)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Linked Phone Numbers *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                            TextButton.icon(
                              icon: const Icon(Icons.add_call, size: 16),
                              label: const Text('Add Another Phone'),
                              onPressed: formCubit.addPhoneNumber,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: state.phoneNumbers.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            return Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: state.phoneNumbers[index],
                                    onChanged: (val) => formCubit.updatePhoneNumber(index, val),
                                    decoration: InputDecoration(
                                      hintText: 'e.g. 01012345678, 011..., 012..., 015...',
                                      prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                                    ),
                                  ),
                                ),
                                if (state.phoneNumbers.length > 1) ...[
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: AppTheme.dangerRed, size: 20),
                                    tooltip: 'Remove phone',
                                    onPressed: () => formCubit.removePhoneNumber(index),
                                  ),
                                ],
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 20),

                        // Address & Email
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Address (Optional)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _addressController,
                                    onChanged: formCubit.setAddress,
                                    decoration: const InputDecoration(
                                      hintText: 'City, Governorate',
                                      prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Email (Optional)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _emailController,
                                    onChanged: formCubit.setEmail,
                                    decoration: const InputDecoration(
                                      hintText: 'customer@example.com',
                                      prefixIcon: Icon(Icons.email_outlined, size: 20),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Custom Fields (P1-1)
                        const Divider(),
                        const SizedBox(height: 12),
                        const Text('Custom Attributes (P1-1)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Preferred Branch', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: AppTheme.textMuted)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _branchController,
                                    onChanged: (val) => formCubit.setCustomField('Preferred Branch', val),
                                    decoration: const InputDecoration(hintText: 'e.g. Nasr City, Smoha'),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('VIP Tier', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12, color: AppTheme.textMuted)),
                                  const SizedBox(height: 6),
                                  TextField(
                                    controller: _vipTierController,
                                    onChanged: (val) => formCubit.setCustomField('VIP Tier', val),
                                    decoration: const InputDecoration(hintText: 'e.g. Gold, Platinum'),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Form Actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            OutlinedButton(
                              onPressed: () => context.pop(),
                              child: const Text('Cancel'),
                            ),
                            const SizedBox(width: 12),
                            ElevatedButton.icon(
                              icon: const Icon(Icons.check, size: 18),
                              label: Text(state.isEdit ? 'Save Changes' : 'Register Customer'),
                              onPressed: state.isSubmitting
                                  ? null
                                  : () => formCubit.submit(listCubit),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
