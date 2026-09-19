import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../customer/presentation/cubit/customer_list_cubit.dart';
import '../../domain/entities/activity.dart';
import '../cubit/activity_cubit.dart';
import '../cubit/activity_state.dart';
import '../widgets/activity_form_dialog.dart';

class ActivityTimelinePage extends StatelessWidget {
  const ActivityTimelinePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Interaction Timeline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              'Chronological feed of customer calls, visits, complaints, and follow-ups',
              style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
            ),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.add_comment, size: 18),
            label: const Text('Log Activity'),
            onPressed: () => ActivityFormDialog.show(context),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Filter by Activity Category / Type
            BlocBuilder<ActivityCubit, ActivityState>(
              builder: (context, state) {
                final selected = state is ActivityLoaded ? state.selectedType : null;

                return Row(
                  children: [
                    const Text('Category: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const SizedBox(width: 8),
                    ...ActivityType.values.map((t) {
                      final isSelected = (t == ActivityType.all && (selected == null || selected == ActivityType.all)) || selected == t;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(t.displayName),
                          selected: isSelected,
                          onSelected: (selectedBool) {
                            if (t == ActivityType.all) {
                              context.read<ActivityCubit>().filterByType(null);
                            } else {
                              context.read<ActivityCubit>().filterByType(selectedBool ? t : null);
                            }
                          },
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
            const SizedBox(height: 20),

            // Timeline List
            Expanded(
              child: BlocBuilder<ActivityCubit, ActivityState>(
                builder: (context, state) {
                  if (state is! ActivityLoaded) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final activities = state.sortedActivities;

                  if (activities.isEmpty) {
                    return const Card(
                      child: Center(
                        child: Text('No activities found.', style: TextStyle(color: AppTheme.textMuted)),
                      ),
                    );
                  }

                  return Card(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: activities.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final act = activities[index];
                        final customer = context.read<CustomerListCubit>().getCustomerById(act.customerId);

                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Type Icon Avatar
                              InkWell(
                                onTap: () => ActivityFormDialog.show(context, activity: act),
                                mouseCursor: SystemMouseCursors.click,
                                borderRadius: BorderRadius.circular(10),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: _getTypeColor(act.type).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    _getTypeIcon(act.type),
                                    color: _getTypeColor(act.type),
                                    size: 22,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Content
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            // Hyperlink Activity Type/Title
                                            InkWell(
                                              onTap: () => ActivityFormDialog.show(context, activity: act),
                                              mouseCursor: SystemMouseCursors.click,
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    act.type.displayName,
                                                    style: TextStyle(
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 15,
                                                      color: _getTypeColor(act.type),
                                                      decoration: TextDecoration.underline,
                                                      decorationColor: _getTypeColor(act.type),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Icon(Icons.edit_outlined, size: 13, color: AppTheme.textMuted),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            const Text('•', style: TextStyle(color: Colors.grey)),
                                            const SizedBox(width: 10),
                                            // Customer hyperlink
                                            InkWell(
                                              onTap: () {
                                                if (customer != null) context.go('/customers/${customer.id}');
                                              },
                                              mouseCursor: SystemMouseCursors.click,
                                              child: Text(
                                                customer?.fullName ?? 'Unknown Customer',
                                                style: const TextStyle(
                                                  color: AppTheme.accentIndigo,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  decoration: TextDecoration.underline,
                                                  decorationColor: AppTheme.accentIndigo,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text(
                                              '${act.timestamp.year}-${act.timestamp.month.toString().padLeft(2, '0')}-${act.timestamp.day.toString().padLeft(2, '0')} ${act.timestamp.hour.toString().padLeft(2, '0')}:${act.timestamp.minute.toString().padLeft(2, '0')}',
                                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                                            ),
                                            const SizedBox(width: 8),
                                            IconButton(
                                              icon: const Icon(Icons.edit_outlined, size: 16),
                                              tooltip: 'Edit Activity',
                                              color: const Color(0xFF475569),
                                              visualDensity: VisualDensity.compact,
                                              onPressed: () => ActivityFormDialog.show(context, activity: act),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.delete_outline, size: 16),
                                              tooltip: 'Delete Activity',
                                              color: AppTheme.dangerRed,
                                              visualDensity: VisualDensity.compact,
                                              onPressed: () => _confirmDelete(context, act),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      act.note,
                                      style: const TextStyle(fontSize: 13, color: AppTheme.textDark, height: 1.4),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, Activity activity) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text('Delete Activity Record'),
        content: Text('Are you sure you want to delete this ${activity.type.displayName} activity? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.dangerRed),
            onPressed: () {
              context.read<ActivityCubit>().deleteActivity(activity.id);
              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Activity record deleted.')),
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(ActivityType type) {
    switch (type) {
      case ActivityType.all:
        return Icons.grid_view_rounded;
      case ActivityType.call:
        return Icons.phone_in_talk;
      case ActivityType.visit:
        return Icons.business;
      case ActivityType.complaint:
        return Icons.warning_amber_rounded;
      case ActivityType.followUp:
        return Icons.assignment_turned_in;
      case ActivityType.other:
        return Icons.chat_bubble_outline;
    }
  }

  Color _getTypeColor(ActivityType type) {
    switch (type) {
      case ActivityType.all:
        return const Color(0xFF6366F1);
      case ActivityType.call:
        return const Color(0xFF0284C7);
      case ActivityType.visit:
        return const Color(0xFF16A34A);
      case ActivityType.complaint:
        return const Color(0xFFDC2626);
      case ActivityType.followUp:
        return const Color(0xFFD97706);
      case ActivityType.other:
        return const Color(0xFF4F46E5);
    }
  }
}
