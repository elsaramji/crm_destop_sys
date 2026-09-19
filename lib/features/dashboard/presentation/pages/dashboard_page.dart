import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../activity/presentation/cubit/activity_cubit.dart';
import '../../../activity/presentation/cubit/activity_state.dart';
import '../../../billing/presentation/cubit/billing_cubit.dart';
import '../../../billing/presentation/cubit/billing_state.dart';
import '../../../customer/presentation/cubit/customer_list_cubit.dart';
import '../../../customer/presentation/cubit/customer_list_state.dart';
import '../../../order/domain/entities/order.dart';
import '../../../order/presentation/cubit/order_cubit.dart';
import '../../../order/presentation/cubit/order_state.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dashboard Overview', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Live operations summary & key performance indicators', style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
          ],
        ),
        actions: [
          ElevatedButton.icon(
            icon: const Icon(Icons.person_add_alt, size: 16),
            label: const Text('New Customer'),
            onPressed: () => context.go('/customers/new'),
          ),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            icon: const Icon(Icons.upload_file, size: 16),
            label: const Text('Excel Center'),
            onPressed: () => context.go('/excel'),
          ),
          const SizedBox(width: 20),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row of 4 KPI Metric Cards (PRD P1-2)
            Row(
              children: [
                // Total Customers
                Expanded(
                  child: BlocBuilder<CustomerListCubit, CustomerListState>(
                    builder: (context, state) {
                      final count = state is CustomerListLoaded ? state.allCustomers.length : 0;
                      return _KpiCard(
                        title: 'Total Customers',
                        value: '$count',
                        icon: Icons.people_outline,
                        color: const Color(0xFF3B82F6),
                        onTap: () => context.go('/customers'),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Open Orders (Pending + In Progress)
                Expanded(
                  child: BlocBuilder<OrderCubit, OrderState>(
                    builder: (context, state) {
                      final count = state is OrderLoaded
                          ? state.allOrders.where((o) => o.status == OrderStatus.pending || o.status == OrderStatus.inProgress).length
                          : 0;
                      return _KpiCard(
                        title: 'Open Orders',
                        value: '$count',
                        icon: Icons.shopping_bag_outlined,
                        color: const Color(0xFFF59E0B),
                        onTap: () => context.go('/orders'),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Unpaid / Outstanding Receivables
                Expanded(
                  child: BlocBuilder<BillingCubit, BillingState>(
                    builder: (context, state) {
                      final receivables = state is BillingLoaded ? state.totalReceivables : 0.0;
                      return _KpiCard(
                        title: 'Unpaid Receivables',
                        value: 'EGP ${receivables.toStringAsFixed(0)}',
                        icon: Icons.receipt_long_outlined,
                        color: const Color(0xFFEF4444),
                        onTap: () => context.go('/billing'),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),

                // Weekly Activities
                Expanded(
                  child: BlocBuilder<ActivityCubit, ActivityState>(
                    builder: (context, state) {
                      final count = state is ActivityLoaded ? state.allActivities.length : 0;
                      return _KpiCard(
                        title: 'Activities Logged',
                        value: '$count',
                        icon: Icons.timeline_outlined,
                        color: const Color(0xFF10B981),
                        onTap: () => context.go('/activities'),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Two-column layout: Recent Customers on Left, Recent Activities on Right
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Recent Customers
                Expanded(
                  flex: 3,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recent Customer Accounts',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.arrow_forward, size: 14),
                                label: const Text('View All'),
                                onPressed: () => context.go('/customers'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          BlocBuilder<CustomerListCubit, CustomerListState>(
                            builder: (context, state) {
                              if (state is! CustomerListLoaded) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              final customers = state.allCustomers.take(5).toList();
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: customers.length,
                                separatorBuilder: (_, __) => const Divider(),
                                itemBuilder: (context, i) {
                                  final c = customers[i];
                                  return ListTile(
                                    contentPadding: EdgeInsets.zero,
                                    leading: CircleAvatar(
                                      backgroundColor: const Color(0xFFEEF2FF),
                                      child: Text(
                                        c.fullName.isNotEmpty ? c.fullName[0].toUpperCase() : 'C',
                                        style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    title: Text(c.fullName, style: const TextStyle(fontWeight: FontWeight.w600)),
                                    subtitle: Text('ID: ${c.nationalId} • ${c.phoneNumbers.firstOrNull ?? "No phone"}'),
                                    trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
                                    onTap: () => context.go('/customers/${c.id}'),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // Recent Activities Timeline
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Latest Interactions',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              TextButton.icon(
                                icon: const Icon(Icons.arrow_forward, size: 14),
                                label: const Text('Timeline'),
                                onPressed: () => context.go('/activities'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          BlocBuilder<ActivityCubit, ActivityState>(
                            builder: (context, state) {
                              if (state is! ActivityLoaded) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              final activities = state.sortedActivities.take(5).toList();
                              return ListView.separated(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: activities.length,
                                separatorBuilder: (_, __) => const Divider(),
                                itemBuilder: (context, i) {
                                  final act = activities[i];
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF1F5F9),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Icon(
                                            Icons.chat_bubble_outline,
                                            size: 16,
                                            color: AppTheme.primaryBlue,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    act.type.displayName,
                                                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                                                  ),
                                                  Text(
                                                    '${act.timestamp.hour.toString().padLeft(2, '0')}:${act.timestamp.minute.toString().padLeft(2, '0')}',
                                                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                act.note,
                                                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
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
    );
  }
}

class _KpiCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _KpiCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13, fontWeight: FontWeight.w500)),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textDark),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
