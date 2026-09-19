$files = @(
    # Core
    'lib/injection.dart',
    'lib/core/di/injection.config.dart',
    'lib/core/error/failures.dart',
    'lib/core/error/exceptions.dart',
    'lib/core/usecase/usecase.dart',
    'lib/core/database/app_database.dart',
    'lib/core/database/tables/customers_table.dart',
    'lib/core/database/tables/customer_phones_table.dart',
    'lib/core/database/tables/services_table.dart',
    'lib/core/database/tables/activities_table.dart',
    'lib/core/database/tables/orders_table.dart',
    'lib/core/database/tables/bills_table.dart',
    'lib/core/database/tables/admins_table.dart',
    'lib/core/theme/app_theme.dart',
    'lib/core/utils/app_constants.dart',

    # Feature: Customer
    'lib/features/customer/domain/entities/customer.dart',
    'lib/features/customer/domain/repositories/customer_repository.dart',
    'lib/features/customer/domain/usecases/create_customer.dart',
    'lib/features/customer/domain/usecases/update_customer.dart',
    'lib/features/customer/domain/usecases/search_customers.dart',
    'lib/features/customer/domain/usecases/get_customer_by_id.dart',
    'lib/features/customer/data/models/customer_model.dart',
    'lib/features/customer/data/datasources/customer_local_datasource.dart',
    'lib/features/customer/data/repositories/customer_repository_impl.dart',
    'lib/features/customer/presentation/cubit/customer_list_cubit.dart',
    'lib/features/customer/presentation/cubit/customer_list_state.dart',
    'lib/features/customer/presentation/cubit/customer_form_cubit.dart',
    'lib/features/customer/presentation/cubit/customer_form_state.dart',
    'lib/features/customer/presentation/pages/customer_list_page.dart',
    'lib/features/customer/presentation/pages/customer_form_page.dart',
    'lib/features/customer/presentation/pages/customer_profile_page.dart',
    'lib/features/customer/presentation/widgets/customer_search_bar.dart',

    # Feature: Service
    'lib/features/service/domain/entities/service_item.dart',
    'lib/features/service/domain/repositories/service_repository.dart',
    'lib/features/service/domain/usecases/add_service.dart',
    'lib/features/service/domain/usecases/get_services_by_customer.dart',
    'lib/features/service/data/models/service_model.dart',
    'lib/features/service/data/datasources/service_local_datasource.dart',
    'lib/features/service/data/repositories/service_repository_impl.dart',
    'lib/features/service/presentation/cubit/service_cubit.dart',
    'lib/features/service/presentation/cubit/service_state.dart',
    'lib/features/service/presentation/pages/service_list_page.dart',
    'lib/features/service/presentation/widgets/service_item_card.dart',

    # Feature: Activity
    'lib/features/activity/domain/entities/activity.dart',
    'lib/features/activity/domain/repositories/activity_repository.dart',
    'lib/features/activity/domain/usecases/log_activity.dart',
    'lib/features/activity/domain/usecases/get_activities_by_customer.dart',
    'lib/features/activity/data/models/activity_model.dart',
    'lib/features/activity/data/datasources/activity_local_datasource.dart',
    'lib/features/activity/data/repositories/activity_repository_impl.dart',
    'lib/features/activity/presentation/cubit/activity_cubit.dart',
    'lib/features/activity/presentation/cubit/activity_state.dart',
    'lib/features/activity/presentation/pages/activity_timeline_page.dart',
    'lib/features/activity/presentation/widgets/activity_timeline_item.dart',

    # Feature: Order
    'lib/features/order/domain/entities/order.dart',
    'lib/features/order/domain/repositories/order_repository.dart',
    'lib/features/order/domain/usecases/create_order.dart',
    'lib/features/order/domain/usecases/update_order_status.dart',
    'lib/features/order/domain/usecases/get_orders_by_customer.dart',
    'lib/features/order/data/models/order_model.dart',
    'lib/features/order/data/datasources/order_local_datasource.dart',
    'lib/features/order/data/repositories/order_repository_impl.dart',
    'lib/features/order/presentation/cubit/order_cubit.dart',
    'lib/features/order/presentation/cubit/order_state.dart',
    'lib/features/order/presentation/pages/order_list_page.dart',
    'lib/features/order/presentation/widgets/order_status_badge.dart',

    # Feature: Billing
    'lib/features/billing/domain/entities/bill.dart',
    'lib/features/billing/domain/repositories/bill_repository.dart',
    'lib/features/billing/domain/usecases/record_bill.dart',
    'lib/features/billing/domain/usecases/update_bill_status.dart',
    'lib/features/billing/domain/usecases/get_bills_by_customer.dart',
    'lib/features/billing/data/models/bill_model.dart',
    'lib/features/billing/data/datasources/bill_local_datasource.dart',
    'lib/features/billing/data/repositories/bill_repository_impl.dart',
    'lib/features/billing/presentation/cubit/billing_cubit.dart',
    'lib/features/billing/presentation/cubit/billing_state.dart',
    'lib/features/billing/presentation/pages/billing_page.dart',
    'lib/features/billing/presentation/widgets/bill_summary_card.dart',

    # Feature: Excel I/O
    'lib/features/excel_io/domain/repositories/excel_io_repository.dart',
    'lib/features/excel_io/domain/usecases/export_to_excel.dart',
    'lib/features/excel_io/domain/usecases/import_from_excel.dart',
    'lib/features/excel_io/data/datasources/excel_local_datasource.dart',
    'lib/features/excel_io/data/repositories/excel_io_repository_impl.dart',
    'lib/features/excel_io/presentation/cubit/excel_io_cubit.dart',
    'lib/features/excel_io/presentation/cubit/excel_io_state.dart',
    'lib/features/excel_io/presentation/pages/excel_io_page.dart',
    'lib/features/excel_io/presentation/widgets/excel_import_dialog.dart',

    # Feature: Auth
    'lib/features/auth/domain/entities/admin_user.dart',
    'lib/features/auth/domain/repositories/auth_repository.dart',
    'lib/features/auth/domain/usecases/login_admin.dart',
    'lib/features/auth/data/datasources/auth_local_datasource.dart',
    'lib/features/auth/data/repositories/auth_repository_impl.dart',
    'lib/features/auth/presentation/cubit/auth_cubit.dart',
    'lib/features/auth/presentation/cubit/auth_state.dart',
    'lib/features/auth/presentation/pages/login_page.dart',
    'lib/features/auth/presentation/widgets/login_card.dart',

    # Tests mirroring structure
    'test/core/error/failures_test.dart',
    'test/core/usecase/usecase_test.dart',

    'test/features/customer/domain/usecases/create_customer_test.dart',
    'test/features/customer/domain/usecases/update_customer_test.dart',
    'test/features/customer/domain/usecases/search_customers_test.dart',
    'test/features/customer/domain/usecases/get_customer_by_id_test.dart',
    'test/features/customer/data/repositories/customer_repository_impl_test.dart',
    'test/features/customer/presentation/cubit/customer_list_cubit_test.dart',
    'test/features/customer/presentation/cubit/customer_form_cubit_test.dart',

    'test/features/service/domain/usecases/add_service_test.dart',
    'test/features/service/domain/usecases/get_services_by_customer_test.dart',
    'test/features/service/data/repositories/service_repository_impl_test.dart',
    'test/features/service/presentation/cubit/service_cubit_test.dart',

    'test/features/activity/domain/usecases/log_activity_test.dart',
    'test/features/activity/domain/usecases/get_activities_by_customer_test.dart',
    'test/features/activity/data/repositories/activity_repository_impl_test.dart',
    'test/features/activity/presentation/cubit/activity_cubit_test.dart',

    'test/features/order/domain/usecases/create_order_test.dart',
    'test/features/order/domain/usecases/update_order_status_test.dart',
    'test/features/order/domain/usecases/get_orders_by_customer_test.dart',
    'test/features/order/data/repositories/order_repository_impl_test.dart',
    'test/features/order/presentation/cubit/order_cubit_test.dart',

    'test/features/billing/domain/usecases/record_bill_test.dart',
    'test/features/billing/domain/usecases/update_bill_status_test.dart',
    'test/features/billing/domain/usecases/get_bills_by_customer_test.dart',
    'test/features/billing/data/repositories/bill_repository_impl_test.dart',
    'test/features/billing/presentation/cubit/billing_cubit_test.dart',

    'test/features/excel_io/domain/usecases/export_to_excel_test.dart',
    'test/features/excel_io/domain/usecases/import_from_excel_test.dart',
    'test/features/excel_io/data/repositories/excel_io_repository_impl_test.dart',
    'test/features/excel_io/presentation/cubit/excel_io_cubit_test.dart',

    'test/features/auth/domain/usecases/login_admin_test.dart',
    'test/features/auth/data/repositories/auth_repository_impl_test.dart',
    'test/features/auth/presentation/cubit/auth_cubit_test.dart'
)

$createdCount = 0
foreach ($f in $files) {
    $dir = Split-Path -Parent $f
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    if (-not (Test-Path $f)) {
        New-Item -ItemType File -Path $f -Force | Out-Null
        $createdCount++
    }
}
Write-Output "Successfully created $createdCount empty files across architecture folders."
