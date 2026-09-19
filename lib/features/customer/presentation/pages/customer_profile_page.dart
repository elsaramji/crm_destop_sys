import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../activity/domain/entities/activity.dart';
import '../../../activity/presentation/cubit/activity_cubit.dart';
import '../../../activity/presentation/cubit/activity_state.dart';
import '../../../billing/domain/entities/bill.dart';
import '../../../billing/presentation/cubit/billing_cubit.dart';
import '../../../billing/presentation/cubit/billing_state.dart';
import '../../../billing/presentation/widgets/ebill_preview_dialog.dart';
import '../../../billing/presentation/widgets/bill_form_dialog.dart';
import '../../../order/domain/entities/order.dart';
import '../../../order/presentation/cubit/order_cubit.dart';
import '../../../order/presentation/cubit/order_state.dart';
import '../../../order/presentation/widgets/order_form_dialog.dart';
import '../../../service/domain/entities/service_item.dart';
import '../../../service/presentation/cubit/service_cubit.dart';
import '../../../service/presentation/cubit/service_state.dart';
import '../../../service/presentation/widgets/service_form_dialog.dart';
import '../../../activity/presentation/widgets/activity_form_dialog.dart';
import '../cubit/customer_list_cubit.dart';
import '../cubit/customer_list_state.dart';


class CustomerProfilePage extends StatefulWidget {
  final String customerId;
  const CustomerProfilePage({super.key, required this.customerId});

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomerListCubit, CustomerListState>(
      builder: (context, listState) {
        if (listState is! CustomerListLoaded) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final customer = context.read<CustomerListCubit>().getCustomerById(widget.customerId);

        if (customer == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Customer Not Found')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.person_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 12),
                  const Text('Customer does not exist or has been deleted.'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/customers'),
                    child: const Text('Back to Customers'),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/customers'),
            ),
            title: Text(customer.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            actions: [
              OutlinedButton.icon(
                icon: const Icon(Icons.edit, size: 16),
                label: const Text('Edit Profile'),
                onPressed: () => context.go('/customers/${customer.id}/edit'),
              ),
              const SizedBox(width: 20),
            ],
          ),
          body: Column(
            children: [
              // Top Profile Summary Card (P0-3)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Avatar
                        CircleAvatar(
                          radius: 36,
                          backgroundColor: const Color(0xFFEEF2FF),
                          child: Text(
                            customer.fullName.isNotEmpty ? customer.fullName[0].toUpperCase() : 'C',
                            style: const TextStyle(color: Color(0xFF4F46E5), fontWeight: FontWeight.bold, fontSize: 28),
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Info Column
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    customer.fullName,
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 12),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEFF6FF),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: const Color(0xFFBFDBFE)),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.badge, size: 14, color: Color(0xFF2563EB)),
                                        const SizedBox(width: 6),
                                        Text(
                                          'ID: ${customer.nationalId}',
                                          style: const TextStyle(
                                            color: Color(0xFF1E40AF),
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'monospace',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (customer.customFields.containsKey('VIP Tier')) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF3C7),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        customer.customFields['VIP Tier']!,
                                        style: const TextStyle(color: Color(0xFFB45309), fontSize: 11, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                              const SizedBox(height: 10),

                              // Phones, Address, Email
                              Wrap(
                                spacing: 16,
                                runSpacing: 6,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.phone, size: 16, color: AppTheme.textMuted),
                                      const SizedBox(width: 6),
                                      Text(
                                        customer.phoneNumbers.join(' • '),
                                        style: const TextStyle(fontSize: 13, color: AppTheme.textDark),
                                      ),
                                    ],
                                  ),
                                  if (customer.address != null)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.location_on, size: 16, color: AppTheme.textMuted),
                                        const SizedBox(width: 6),
                                        Text(customer.address!, style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
                                      ],
                                    ),
                                  if (customer.email != null)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.email, size: 16, color: AppTheme.textMuted),
                                        const SizedBox(width: 6),
                                        Text(customer.email!, style: const TextStyle(fontSize: 13, color: AppTheme.textDark)),
                                      ],
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Balance snapshot widget
                        BlocBuilder<BillingCubit, BillingState>(
                          builder: (context, billState) {
                            final balance = context.read<BillingCubit>().getCustomerBalanceSummary(customer.id);
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                              decoration: BoxDecoration(
                                color: balance.outstandingBalance > 0 ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: balance.outstandingBalance > 0 ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  const Text('Outstanding Balance', style: TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                                  const SizedBox(height: 4),
                                  Text(
                                    'EGP ${balance.outstandingBalance.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: balance.outstandingBalance > 0 ? AppTheme.dangerRed : AppTheme.successGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Total Billed: EGP ${balance.totalBilled.toStringAsFixed(0)}',
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primaryBlue,
                  unselectedLabelColor: AppTheme.textMuted,
                  indicatorColor: AppTheme.accentIndigo,
                  indicatorWeight: 3,
                  tabs: const [
                    Tab(icon: Icon(Icons.design_services, size: 18), text: 'Services (P0-4)'),
                    Tab(icon: Icon(Icons.timeline, size: 18), text: 'Activity Timeline (P0-5)'),
                    Tab(icon: Icon(Icons.shopping_bag, size: 18), text: 'Orders (P0-6)'),
                    Tab(icon: Icon(Icons.receipt_long, size: 18), text: 'Bills & Balance (P0-7)'),
                  ],
                ),
              ),

              // Tab Views
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _CustomerServicesTab(customerId: customer.id),
                      _CustomerActivitiesTab(customerId: customer.id),
                      _CustomerOrdersTab(customerId: customer.id),
                      _CustomerBillsTab(customerId: customer.id),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// -------------------------------------------------------------
// TAB 1: Services (P0-4)
// -------------------------------------------------------------
class _CustomerServicesTab extends StatelessWidget {
  final String customerId;
  const _CustomerServicesTab({required this.customerId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ServiceCubit, ServiceState>(
      builder: (context, state) {
        final services = context.read<ServiceCubit>().getServicesForCustomer(customerId);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Provided Services (${services.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Service'),
                      onPressed: () => ServiceFormDialog.show(context, defaultCustomerId: customerId),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (services.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('No services recorded for this customer yet.', style: TextStyle(color: AppTheme.textMuted)),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: services.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final s = services[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          onTap: () => ServiceFormDialog.show(context, service: s, defaultCustomerId: customerId),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: const Color(0xFFEFF6FF),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.build_circle_outlined, color: AppTheme.primaryBlue),
                          ),
                          title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('Category: ${s.category} • Provided: ${s.dateProvided.year}-${s.dateProvided.month.toString().padLeft(2, '0')}-${s.dateProvided.day.toString().padLeft(2, '0')}\n${s.notes ?? ""}'),
                          trailing: Text(
                            'EGP ${s.price.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryBlue),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// -------------------------------------------------------------
// TAB 2: Activities Timeline (P0-5)
// -------------------------------------------------------------
class _CustomerActivitiesTab extends StatelessWidget {
  final String customerId;
  const _CustomerActivitiesTab({required this.customerId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ActivityCubit, ActivityState>(
      builder: (context, state) {
        final activities = context.read<ActivityCubit>().getActivitiesForCustomer(customerId);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Activity Timeline (${activities.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_comment, size: 16),
                      label: const Text('Log Activity'),
                      onPressed: () => ActivityFormDialog.show(context, defaultCustomerId: customerId),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (activities.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('No activities logged for this customer yet.', style: TextStyle(color: AppTheme.textMuted)),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: activities.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final act = activities[index];
                        return InkWell(
                          onTap: () => ActivityFormDialog.show(context, activity: act, defaultCustomerId: customerId),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  act.type == ActivityType.all
                                      ? Icons.grid_view_rounded
                                      : act.type == ActivityType.call
                                          ? Icons.phone_in_talk
                                          : act.type == ActivityType.visit
                                              ? Icons.business
                                              : act.type == ActivityType.complaint
                                                  ? Icons.warning_amber
                                                  : act.type == ActivityType.followUp
                                                      ? Icons.assignment_turned_in
                                                      : Icons.chat_bubble_outline,
                                  color: AppTheme.accentIndigo,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(act.type.displayName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        Text(
                                          '${act.timestamp.year}-${act.timestamp.month.toString().padLeft(2, '0')}-${act.timestamp.day.toString().padLeft(2, '0')} ${act.timestamp.hour.toString().padLeft(2, '0')}:${act.timestamp.minute.toString().padLeft(2, '0')}',
                                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(act.note, style: const TextStyle(fontSize: 13)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// -------------------------------------------------------------
// TAB 3: Orders (P0-6)
// -------------------------------------------------------------
class _CustomerOrdersTab extends StatelessWidget {
  final String customerId;
  const _CustomerOrdersTab({required this.customerId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<OrderCubit, OrderState>(
      builder: (context, state) {
        final orders = context.read<OrderCubit>().getOrdersForCustomer(customerId);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Customer Orders (${orders.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add_shopping_cart, size: 16),
                      label: const Text('Create Order'),
                      onPressed: () => OrderFormDialog.show(context, defaultCustomerId: customerId),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (orders.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('No orders created for this customer yet.', style: TextStyle(color: AppTheme.textMuted)),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: orders.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final o = orders[index];
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          onTap: () => OrderFormDialog.show(context, order: o, defaultCustomerId: customerId),
                          title: Row(
                            children: [
                              Text('Order #${o.id.length > 6 ? o.id.substring(o.id.length - 6) : o.id}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              const SizedBox(width: 12),
                              _buildStatusBadge(o.status),
                            ],
                          ),
                          subtitle: Text('Items: ${o.items.join(", ")}\nDate: ${o.createdAt.year}-${o.createdAt.month.toString().padLeft(2, '0')}-${o.createdAt.day.toString().padLeft(2, '0')}'),
                          trailing: Text(
                            'EGP ${o.totalAmount.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(OrderStatus status) {
    Color bg;
    Color fg;
    switch (status) {
      case OrderStatus.pending:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        break;
      case OrderStatus.inProgress:
        bg = const Color(0xFFE0E7FF);
        fg = const Color(0xFF4338CA);
        break;
      case OrderStatus.completed:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
      case OrderStatus.cancelled:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status.displayName, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}

// -------------------------------------------------------------
// TAB 4: Bills & Balance (P0-7)
// -------------------------------------------------------------
class _CustomerBillsTab extends StatelessWidget {
  final String customerId;
  const _CustomerBillsTab({required this.customerId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BillingCubit, BillingState>(
      builder: (context, state) {
        final bills = context.read<BillingCubit>().getBillsForCustomer(customerId);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Invoices & Bills (${bills.length})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.receipt, size: 16),
                      label: const Text('Record Bill'),
                      onPressed: () => BillFormDialog.show(context, defaultCustomerId: customerId),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (bills.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Text('No billing records found for this customer.', style: TextStyle(color: AppTheme.textMuted)),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: bills.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final b = bills[index];
                        final customer = context.read<CustomerListCubit>().getCustomerById(customerId);
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          onTap: () => EBillPreviewDialog.show(context, bill: b, customer: customer),
                          title: Row(
                            children: [
                              Text(b.description ?? 'Bill #${b.id.length > 6 ? b.id.substring(b.id.length - 6) : b.id}', style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline, decorationColor: AppTheme.primaryBlue, color: AppTheme.primaryBlue)),
                              const SizedBox(width: 6),
                              const Icon(Icons.picture_as_pdf, size: 14, color: Colors.redAccent),
                              const SizedBox(width: 10),
                              _buildStatusBadge(b.status),
                            ],
                          ),
                          subtitle: Text('Issued: ${b.issuedAt.year}-${b.issuedAt.month.toString().padLeft(2, '0')}-${b.issuedAt.day.toString().padLeft(2, '0')} • Due: ${b.dueDate.year}-${b.dueDate.month.toString().padLeft(2, '0')}-${b.dueDate.day.toString().padLeft(2, '0')}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text('Total: EGP ${b.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                'Paid: EGP ${b.paidAmount.toStringAsFixed(2)} (Remaining: EGP ${b.remainingAmount.toStringAsFixed(2)})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: b.remainingAmount > 0 ? AppTheme.dangerRed : AppTheme.successGreen,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusBadge(BillStatus status) {
    Color bg;
    Color fg;
    switch (status) {
      case BillStatus.paid:
        bg = const Color(0xFFDCFCE7);
        fg = const Color(0xFF15803D);
        break;
      case BillStatus.unpaid:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFB91C1C);
        break;
      case BillStatus.partial:
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFB45309);
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
      child: Text(status.displayName, style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }
}
