import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/customer.dart';
import '../cubit/customer_list_cubit.dart';
import '../cubit/customer_lookup_cubit.dart';
import '../cubit/customer_lookup_state.dart';

class CustomerIdLookupField extends StatelessWidget {
  final String? initialCustomerId;
  final ValueChanged<Customer?> onCustomerSelected;
  final bool isRequired;
  final String labelText;

  const CustomerIdLookupField({
    super.key,
    this.initialCustomerId,
    required this.onCustomerSelected,
    this.isRequired = true,
    this.labelText = 'Customer Account (Enter ID Number) *',
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<CustomerLookupCubit>(
      create: (ctx) => CustomerLookupCubit(ctx.read<CustomerListCubit>())
        ..init(initialCustomerId),
      child: _CustomerIdLookupContent(
        initialCustomerId: initialCustomerId,
        onCustomerSelected: onCustomerSelected,
        isRequired: isRequired,
        labelText: labelText,
      ),
    );
  }
}

class _CustomerIdLookupContent extends StatefulWidget {
  final String? initialCustomerId;
  final ValueChanged<Customer?> onCustomerSelected;
  final bool isRequired;
  final String labelText;

  const _CustomerIdLookupContent({
    required this.initialCustomerId,
    required this.onCustomerSelected,
    required this.isRequired,
    required this.labelText,
  });

  @override
  State<_CustomerIdLookupContent> createState() => _CustomerIdLookupContentState();
}

class _CustomerIdLookupContentState extends State<_CustomerIdLookupContent> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void didUpdateWidget(covariant _CustomerIdLookupContent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialCustomerId != oldWidget.initialCustomerId) {
      context.read<CustomerLookupCubit>().init(widget.initialCustomerId);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CustomerLookupCubit, CustomerLookupState>(
      listener: (context, state) {
        if (_controller.text != state.query) {
          _controller.value = TextEditingValue(
            text: state.query,
            selection: TextSelection.collapsed(offset: state.query.length),
          );
        }
        widget.onCustomerSelected(state.selectedCustomer);
      },
      builder: (context, state) {
        final selected = state.selectedCustomer;
        final cubit = context.read<CustomerLookupCubit>();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _controller,
              onChanged: (val) => cubit.searchById(val),
              decoration: InputDecoration(
                labelText: widget.labelText,
                hintText: 'Enter National ID (e.g. 29501011234567) or Customer ID',
                prefixIcon: const Icon(Icons.badge_outlined),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (selected != null)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: AppTheme.successGreen,
                          size: 22,
                        ),
                      )
                    else if (state.hasSearched && _controller.text.trim().isNotEmpty)
                      const Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.error_outline_rounded,
                          color: AppTheme.warningAmber,
                          size: 22,
                        ),
                      ),
                    if (_controller.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        tooltip: 'Clear ID',
                        onPressed: () => cubit.clear(),
                      ),
                  ],
                ),
              ),
              validator: (val) {
                if (widget.isRequired) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter customer ID or National ID';
                  }
                  if (selected == null) {
                    return 'No customer matches this ID. Please check the number';
                  }
                }
                return null;
              },
            ),

            // Customer preview card when found
            if (selected != null) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppTheme.primaryBlue,
                      child: Text(
                        selected.fullName.isNotEmpty
                            ? selected.fullName[0].toUpperCase()
                            : 'C',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  selected.fullName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: AppTheme.textDark,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: const Color(0xFF86EFAC)),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.check_circle, size: 11, color: AppTheme.successGreen),
                                    SizedBox(width: 3),
                                    Text(
                                      'Verified',
                                      style: TextStyle(
                                        color: AppTheme.successGreen,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Wrap(
                            spacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.credit_card, size: 13, color: AppTheme.textMuted),
                                  const SizedBox(width: 4),
                                  Text(
                                    'ID: ${selected.nationalId}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppTheme.textMuted,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              if (selected.phoneNumbers.isNotEmpty)
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.phone_outlined, size: 13, color: AppTheme.textMuted),
                                    const SizedBox(width: 4),
                                    Text(
                                      selected.phoneNumbers.first,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                              if (selected.customFields.containsKey('Preferred Branch'))
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.business_outlined, size: 13, color: AppTheme.textMuted),
                                    const SizedBox(width: 4),
                                    Text(
                                      selected.customFields['Preferred Branch']!,
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppTheme.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Warning message when text is entered but not matched
            if (selected == null && state.hasSearched && _controller.text.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFDE68A)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_off_outlined, color: AppTheme.warningAmber, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No customer found matching "${_controller.text.trim()}". Please verify the National ID or Account ID.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Suggestions list if partial matches exist
            if (state.suggestions.isNotEmpty) ...[
              const SizedBox(height: 8),
              const Text(
                'Suggestions (tap to select):',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: state.suggestions.map((c) {
                  return ActionChip(
                    visualDensity: VisualDensity.compact,
                    avatar: const Icon(Icons.person_outline, size: 14),
                    label: Text(
                      '${c.fullName} (${c.nationalId})',
                      style: const TextStyle(fontSize: 11),
                    ),
                    onPressed: () => cubit.selectCustomer(c),
                  );
                }).toList(),
              ),
            ],
          ],
        );
      },
    );
  }
}
