import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/shell/presentation/pages/app_shell.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page.dart';
import '../../features/customer/presentation/pages/customer_list_page.dart';
import '../../features/customer/presentation/pages/customer_form_page.dart';
import '../../features/customer/presentation/pages/customer_profile_page.dart';
import '../../features/service/presentation/pages/service_list_page.dart';
import '../../features/activity/presentation/pages/activity_timeline_page.dart';
import '../../features/order/presentation/pages/order_list_page.dart';
import '../../features/billing/presentation/pages/billing_page.dart';
import '../../features/excel_io/presentation/pages/excel_io_page.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthCubit authCubit) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/dashboard',
      redirect: (context, state) {
        final authState = authCubit.state;
        final isLoggingIn = state.uri.toString() == '/login';

        if (authState is Unauthenticated && !isLoggingIn) {
          return '/login';
        }

        if (authState is Authenticated && isLoggingIn) {
          return '/dashboard';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        ShellRoute(
          navigatorKey: _shellNavigatorKey,
          builder: (context, state, child) => AppShell(child: child),
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => const DashboardPage(),
            ),
            GoRoute(
              path: '/customers',
              builder: (context, state) => const CustomerListPage(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (context, state) => const CustomerFormPage(),
                ),
                GoRoute(
                  path: ':id',
                  builder: (context, state) {
                    final customerId = state.pathParameters['id'] ?? '';
                    return CustomerProfilePage(customerId: customerId);
                  },
                  routes: [
                    GoRoute(
                      path: 'edit',
                      builder: (context, state) {
                        final customerId = state.pathParameters['id'];
                        return CustomerFormPage(customerId: customerId);
                      },
                    ),
                  ],
                ),
              ],
            ),
            GoRoute(
              path: '/services',
              builder: (context, state) => const ServiceListPage(),
            ),
            GoRoute(
              path: '/activities',
              builder: (context, state) => const ActivityTimelinePage(),
            ),
            GoRoute(
              path: '/orders',
              builder: (context, state) => const OrderListPage(),
            ),
            GoRoute(
              path: '/billing',
              builder: (context, state) => const BillingPage(),
            ),
            GoRoute(
              path: '/excel',
              builder: (context, state) => const ExcelIoPage(),
            ),
          ],
        ),
      ],
    );
  }
}
