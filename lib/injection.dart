import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'core/database/app_database.dart';

// Customer Feature
import 'features/customer/data/datasources/customer_local_datasource.dart';
import 'features/customer/data/repositories/customer_repository_impl.dart';
import 'features/customer/domain/repositories/customer_repository.dart';
import 'features/customer/domain/usecases/create_customer.dart';
import 'features/customer/domain/usecases/delete_customer.dart';
import 'features/customer/domain/usecases/get_customer_by_id.dart';
import 'features/customer/domain/usecases/get_customers.dart';
import 'features/customer/domain/usecases/search_customers.dart';
import 'features/customer/domain/usecases/update_customer.dart';
import 'features/customer/presentation/cubit/customer_list_cubit.dart';
import 'features/customer/presentation/cubit/customer_form_cubit.dart';

// Service Feature
import 'features/service/data/datasources/service_local_datasource.dart';
import 'features/service/data/repositories/service_repository_impl.dart';
import 'features/service/domain/repositories/service_repository.dart';
import 'features/service/domain/usecases/add_service.dart';
import 'features/service/domain/usecases/delete_service.dart';
import 'features/service/domain/usecases/get_all_services.dart';
import 'features/service/domain/usecases/get_services_by_customer.dart';
import 'features/service/domain/usecases/update_service.dart';
import 'features/service/presentation/cubit/service_cubit.dart';

// Activity Feature
import 'features/activity/data/datasources/activity_local_datasource.dart';
import 'features/activity/data/repositories/activity_repository_impl.dart';
import 'features/activity/domain/repositories/activity_repository.dart';
import 'features/activity/domain/usecases/delete_activity.dart';
import 'features/activity/domain/usecases/get_activities_by_customer.dart';
import 'features/activity/domain/usecases/get_all_activities.dart';
import 'features/activity/domain/usecases/log_activity.dart';
import 'features/activity/domain/usecases/update_activity.dart';
import 'features/activity/presentation/cubit/activity_cubit.dart';

// Order Feature
import 'features/order/data/datasources/order_local_datasource.dart';
import 'features/order/data/repositories/order_repository_impl.dart';
import 'features/order/domain/repositories/order_repository.dart';
import 'features/order/domain/usecases/create_order.dart';
import 'features/order/domain/usecases/delete_order.dart';
import 'features/order/domain/usecases/get_all_orders.dart';
import 'features/order/domain/usecases/get_orders_by_customer.dart';
import 'features/order/domain/usecases/update_order.dart';
import 'features/order/domain/usecases/update_order_status.dart';
import 'features/order/presentation/cubit/order_cubit.dart';

// Billing Feature
import 'features/billing/data/datasources/billing_local_datasource.dart';
import 'features/billing/data/repositories/billing_repository_impl.dart';
import 'features/billing/domain/repositories/billing_repository.dart';
import 'features/billing/domain/usecases/delete_bill.dart';
import 'features/billing/domain/usecases/get_all_bills.dart';
import 'features/billing/domain/usecases/get_bills_by_customer.dart';
import 'features/billing/domain/usecases/record_bill.dart';
import 'features/billing/domain/usecases/update_bill.dart';
import 'features/billing/domain/usecases/update_bill_status.dart';
import 'features/billing/presentation/cubit/billing_cubit.dart';

// Auth Feature
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/login.dart';
import 'features/auth/domain/usecases/logout.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';

// Excel Feature
import 'features/excel_io/data/datasources/excel_local_datasource.dart';
import 'features/excel_io/data/repositories/excel_io_repository_impl.dart';
import 'features/excel_io/domain/repositories/excel_io_repository.dart';
import 'features/excel_io/domain/usecases/export_to_excel.dart';
import 'features/excel_io/domain/usecases/import_from_excel.dart';
import 'features/excel_io/presentation/cubit/excel_io_cubit.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  // Database
  final db = AppDatabase();
  await db.seedIfEmpty();
  getIt.registerSingleton<AppDatabase>(db);

  // Customer Feature
  getIt.registerLazySingleton<CustomerLocalDatasource>(
    () => CustomerLocalDatasourceImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<CustomerRepository>(
    () => CustomerRepositoryImpl(getIt<CustomerLocalDatasource>()),
  );
  getIt.registerLazySingleton(() => GetCustomers(getIt<CustomerRepository>()));
  getIt.registerLazySingleton(() => GetCustomerById(getIt<CustomerRepository>()));
  getIt.registerLazySingleton(() => CreateCustomer(getIt<CustomerRepository>()));
  getIt.registerLazySingleton(() => UpdateCustomer(getIt<CustomerRepository>()));
  getIt.registerLazySingleton(() => DeleteCustomer(getIt<CustomerRepository>()));
  getIt.registerLazySingleton(() => SearchCustomers(getIt<CustomerRepository>()));
  getIt.registerFactory(() => CustomerListCubit(
    getCustomers: getIt<GetCustomers>(),
    createCustomer: getIt<CreateCustomer>(),
    updateCustomer: getIt<UpdateCustomer>(),
    deleteCustomer: getIt<DeleteCustomer>(),
    searchCustomers: getIt<SearchCustomers>(),
  ));
  getIt.registerFactory(() => CustomerFormCubit());

  // Service Feature
  getIt.registerLazySingleton<ServiceLocalDatasource>(
    () => ServiceLocalDatasourceImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<ServiceRepository>(
    () => ServiceRepositoryImpl(getIt<ServiceLocalDatasource>()),
  );
  getIt.registerLazySingleton(() => GetAllServices(getIt<ServiceRepository>()));
  getIt.registerLazySingleton(() => GetServicesByCustomer(getIt<ServiceRepository>()));
  getIt.registerLazySingleton(() => AddService(getIt<ServiceRepository>()));
  getIt.registerLazySingleton(() => UpdateService(getIt<ServiceRepository>()));
  getIt.registerLazySingleton(() => DeleteService(getIt<ServiceRepository>()));
  getIt.registerFactory(() => ServiceCubit(
    getAllServices: getIt<GetAllServices>(),
    getServicesByCustomer: getIt<GetServicesByCustomer>(),
    addService: getIt<AddService>(),
    updateService: getIt<UpdateService>(),
    deleteService: getIt<DeleteService>(),
  ));

  // Activity Feature
  getIt.registerLazySingleton<ActivityLocalDatasource>(
    () => ActivityLocalDatasourceImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<ActivityRepository>(
    () => ActivityRepositoryImpl(getIt<ActivityLocalDatasource>()),
  );
  getIt.registerLazySingleton(() => GetAllActivities(getIt<ActivityRepository>()));
  getIt.registerLazySingleton(() => GetActivitiesByCustomer(getIt<ActivityRepository>()));
  getIt.registerLazySingleton(() => LogActivity(getIt<ActivityRepository>()));
  getIt.registerLazySingleton(() => UpdateActivity(getIt<ActivityRepository>()));
  getIt.registerLazySingleton(() => DeleteActivity(getIt<ActivityRepository>()));
  getIt.registerFactory(() => ActivityCubit(
    getAllActivities: getIt<GetAllActivities>(),
    getActivitiesByCustomer: getIt<GetActivitiesByCustomer>(),
    logActivity: getIt<LogActivity>(),
    updateActivity: getIt<UpdateActivity>(),
    deleteActivity: getIt<DeleteActivity>(),
  ));

  // Order Feature
  getIt.registerLazySingleton<OrderLocalDatasource>(
    () => OrderLocalDatasourceImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(getIt<OrderLocalDatasource>()),
  );
  getIt.registerLazySingleton(() => GetAllOrders(getIt<OrderRepository>()));
  getIt.registerLazySingleton(() => GetOrdersByCustomer(getIt<OrderRepository>()));
  getIt.registerLazySingleton(() => CreateOrder(getIt<OrderRepository>()));
  getIt.registerLazySingleton(() => UpdateOrder(getIt<OrderRepository>()));
  getIt.registerLazySingleton(() => UpdateOrderStatus(getIt<OrderRepository>()));
  getIt.registerLazySingleton(() => DeleteOrder(getIt<OrderRepository>()));
  getIt.registerFactory(() => OrderCubit(
    getAllOrders: getIt<GetAllOrders>(),
    getOrdersByCustomer: getIt<GetOrdersByCustomer>(),
    createOrder: getIt<CreateOrder>(),
    updateOrder: getIt<UpdateOrder>(),
    updateOrderStatus: getIt<UpdateOrderStatus>(),
    deleteOrder: getIt<DeleteOrder>(),
  ));

  // Billing Feature
  getIt.registerLazySingleton<BillingLocalDatasource>(
    () => BillingLocalDatasourceImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<BillingRepository>(
    () => BillingRepositoryImpl(getIt<BillingLocalDatasource>()),
  );
  getIt.registerLazySingleton(() => GetAllBills(getIt<BillingRepository>()));
  getIt.registerLazySingleton(() => GetBillsByCustomer(getIt<BillingRepository>()));
  getIt.registerLazySingleton(() => RecordBill(getIt<BillingRepository>()));
  getIt.registerLazySingleton(() => UpdateBill(getIt<BillingRepository>()));
  getIt.registerLazySingleton(() => UpdateBillStatus(getIt<BillingRepository>()));
  getIt.registerLazySingleton(() => DeleteBill(getIt<BillingRepository>()));
  getIt.registerFactory(() => BillingCubit(
    getAllBills: getIt<GetAllBills>(),
    getBillsByCustomer: getIt<GetBillsByCustomer>(),
    recordBill: getIt<RecordBill>(),
    updateBill: getIt<UpdateBill>(),
    updateBillStatus: getIt<UpdateBillStatus>(),
    deleteBill: getIt<DeleteBill>(),
  ));

  // Auth Feature
  getIt.registerLazySingleton<AuthLocalDatasource>(
    () => AuthLocalDatasourceImpl(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(getIt<AuthLocalDatasource>()),
  );
  getIt.registerLazySingleton(() => Login(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => GetCurrentUser(getIt<AuthRepository>()));
  getIt.registerLazySingleton(() => Logout(getIt<AuthRepository>()));
  getIt.registerFactory(() => AuthCubit(
    login: getIt<Login>(),
    getCurrentUser: getIt<GetCurrentUser>(),
    logout: getIt<Logout>(),
  ));

  // Excel Feature
  getIt.registerLazySingleton<ExcelLocalDatasource>(
    () => ExcelLocalDatasourceImpl(),
  );
  getIt.registerLazySingleton<ExcelIoRepository>(
    () => ExcelIoRepositoryImpl(
      localDatasource: getIt<ExcelLocalDatasource>(),
      customerRepository: getIt<CustomerRepository>(),
      serviceRepository: getIt<ServiceRepository>(),
      activityRepository: getIt<ActivityRepository>(),
      orderRepository: getIt<OrderRepository>(),
      billingRepository: getIt<BillingRepository>(),
    ),
  );
  getIt.registerLazySingleton(() => ExportToExcel(getIt<ExcelIoRepository>()));
  getIt.registerLazySingleton(() => ImportFromExcel(getIt<ExcelIoRepository>()));
  getIt.registerFactory(() => ExcelIoCubit(
    exportToExcel: getIt<ExportToExcel>(),
    importFromExcel: getIt<ImportFromExcel>(),
  ));
}
