import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/customer/presentation/cubit/customer_list_cubit.dart';
import 'features/customer/presentation/cubit/customer_form_cubit.dart';
import 'features/service/presentation/cubit/service_cubit.dart';
import 'features/activity/presentation/cubit/activity_cubit.dart';
import 'features/order/presentation/cubit/order_cubit.dart';
import 'features/billing/presentation/cubit/billing_cubit.dart';
import 'features/excel_io/presentation/cubit/excel_io_cubit.dart';
import 'injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // HydratedBloc desktop storage initialization per rules.md
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationSupportDirectory()).path,
    ),
  );

  // Initialize SQLite database and dependency injection container
  await configureDependencies();

  runApp(const CrmApp());
}

class CrmApp extends StatefulWidget {
  const CrmApp({super.key});

  @override
  State<CrmApp> createState() => _CrmAppState();
}

class _CrmAppState extends State<CrmApp> {
  late final AuthCubit _authCubit;
  late final CustomerListCubit _customerListCubit;
  late final CustomerFormCubit _customerFormCubit;
  late final ServiceCubit _serviceCubit;
  late final ActivityCubit _activityCubit;
  late final OrderCubit _orderCubit;
  late final BillingCubit _billingCubit;
  late final ExcelIoCubit _excelIoCubit;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Resolve cubits via GetIt DI container
    _authCubit = getIt<AuthCubit>();
    _customerListCubit = getIt<CustomerListCubit>();
    _customerFormCubit = getIt<CustomerFormCubit>();
    _serviceCubit = getIt<ServiceCubit>();
    _activityCubit = getIt<ActivityCubit>();
    _orderCubit = getIt<OrderCubit>();
    _billingCubit = getIt<BillingCubit>();
    _excelIoCubit = getIt<ExcelIoCubit>();

    _router = AppRouter.createRouter(_authCubit);
  }

  @override
  void dispose() {
    _authCubit.close();
    _customerListCubit.close();
    _customerFormCubit.close();
    _serviceCubit.close();
    _activityCubit.close();
    _orderCubit.close();
    _billingCubit.close();
    _excelIoCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>.value(value: _authCubit),
        BlocProvider<CustomerListCubit>.value(value: _customerListCubit),
        BlocProvider<CustomerFormCubit>.value(value: _customerFormCubit),
        BlocProvider<ServiceCubit>.value(value: _serviceCubit),
        BlocProvider<ActivityCubit>.value(value: _activityCubit),
        BlocProvider<OrderCubit>.value(value: _orderCubit),
        BlocProvider<BillingCubit>.value(value: _billingCubit),
        BlocProvider<ExcelIoCubit>.value(value: _excelIoCubit),
      ],
      child: MaterialApp.router(
        title: 'CRM Desktop System (Egypt Market)',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        routerConfig: _router,
      ),
    );
  }
}
