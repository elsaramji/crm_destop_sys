import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../activity/presentation/cubit/activity_cubit.dart';
import '../../../activity/presentation/cubit/activity_state.dart';
import '../../../billing/presentation/cubit/billing_cubit.dart';
import '../../../billing/presentation/cubit/billing_state.dart';
import '../../../customer/domain/entities/customer.dart';
import '../../../customer/presentation/cubit/customer_list_cubit.dart';
import '../../../customer/presentation/cubit/customer_list_state.dart';
import '../../../order/presentation/cubit/order_cubit.dart';
import '../../../order/presentation/cubit/order_state.dart';
import '../../../service/presentation/cubit/service_cubit.dart';
import '../../../service/presentation/cubit/service_state.dart';
import 'excel_io_state.dart';

class ExcelIoCubit extends Cubit<ExcelIoState> {
  ExcelIoCubit() : super(const ExcelIoInitial());

  Future<void> exportAllData({
    required CustomerListCubit customerCubit,
    required ServiceCubit serviceCubit,
    required ActivityCubit activityCubit,
    required OrderCubit orderCubit,
    required BillingCubit billingCubit,
  }) async {
    emit(const ExcelIoProcessing('Compiling data sheets for export...'));
    await Future.delayed(const Duration(milliseconds: 600));

    final customers = customerCubit.state is CustomerListLoaded
        ? (customerCubit.state as CustomerListLoaded).allCustomers
        : <Customer>[];
    final services = serviceCubit.state is ServiceLoaded
        ? (serviceCubit.state as ServiceLoaded).allServices
        : [];
    final activities = activityCubit.state is ActivityLoaded
        ? (activityCubit.state as ActivityLoaded).allActivities
        : [];
    final orders = orderCubit.state is OrderLoaded
        ? (orderCubit.state as OrderLoaded).allOrders
        : [];
    final bills = billingCubit.state is BillingLoaded
        ? (billingCubit.state as BillingLoaded).allBills
        : [];

    final filename = 'CRM_Export_${DateTime.now().year}_${DateTime.now().month.toString().padLeft(2, '0')}_${DateTime.now().day.toString().padLeft(2, '0')}.xlsx';

    emit(ExcelExportSuccess(
      filename: filename,
      customersCount: customers.length,
      servicesCount: services.length,
      activitiesCount: activities.length,
      ordersCount: orders.length,
      billsCount: bills.length,
      exportedAt: DateTime.now(),
    ));
  }

  Future<void> simulateImport({required CustomerListCubit customerCubit}) async {
    emit(const ExcelIoProcessing('Parsing imported .xlsx spreadsheet and checking validation rules...'));
    await Future.delayed(const Duration(milliseconds: 700));

    // Simulated rows from sample Excel file
    final sampleRows = [
      {
        'National ID': '29602021408899',
        'Name': 'Ibrahim Samir Qasim',
        'Phone': '01099887766',
        'Address': 'Nasr City, Cairo',
        'Status': 'Valid - New Record',
      },
      {
        'National ID': '29501011234567', // Duplicate of Ahmed Hassan
        'Name': 'Ahmed Mahmoud Hassan',
        'Phone': '01012345678',
        'Address': 'Cairo',
        'Status': 'Duplicate National ID (Already in DB)',
      },
      {
        'National ID': '29811111903344',
        'Name': 'Nourhan Essam Tawfik',
        'Phone': '01155443322',
        'Address': 'Mohandessin, Giza',
        'Status': 'Valid - New Record',
      },
      {
        'National ID': '291030', // Malformed (short ID)
        'Name': 'Hossam Badran',
        'Phone': 'invalid-phone',
        'Address': 'Alexandria',
        'Status': 'Malformed - Invalid National ID & Phone format',
      },
    ];

    // Add new valid customer to list
    final newCustomer = Customer(
      id: 'cust_imp_${DateTime.now().millisecondsSinceEpoch}',
      nationalId: '29602021408899',
      fullName: 'Ibrahim Samir Qasim',
      phoneNumbers: const ['01099887766'],
      address: 'Nasr City, Cairo',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    customerCubit.addCustomer(newCustomer);

    emit(ExcelImportSuccess(
      ExcelImportReport(
        totalRows: 4,
        validRowsCount: 2,
        duplicateNationalIds: const ['29501011234567 (Ahmed Mahmoud Hassan)'],
        malformedRowErrors: const [
          'Row 4: National ID "291030" must be 14 digits; Phone "invalid-phone" is invalid format.',
        ],
        importedSampleRows: sampleRows,
      ),
    ));
  }

  void reset() {
    emit(const ExcelIoInitial());
  }
}
