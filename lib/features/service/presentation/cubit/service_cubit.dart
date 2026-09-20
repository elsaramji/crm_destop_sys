import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/service_item.dart';
import '../../domain/usecases/add_service.dart';
import '../../domain/usecases/delete_service.dart';
import '../../domain/usecases/get_all_services.dart';
import '../../domain/usecases/get_services_by_customer.dart';
import '../../domain/usecases/update_service.dart';
import 'service_state.dart';

class ServiceCubit extends Cubit<ServiceState> {
  final GetAllServices _getAllServices;
  final GetServicesByCustomer _getServicesByCustomer;
  final AddService _addService;
  final UpdateService _updateService;
  final DeleteService _deleteService;

  ServiceCubit({
    required GetAllServices getAllServices,
    required GetServicesByCustomer getServicesByCustomer,
    required AddService addService,
    required UpdateService updateService,
    required DeleteService deleteService,
  })  : _getAllServices = getAllServices,
        _getServicesByCustomer = getServicesByCustomer,
        _addService = addService,
        _updateService = updateService,
        _deleteService = deleteService,
        super(const ServiceLoading()) {
    loadServices();
  }

  Future<void> loadServices() async {
    emit(const ServiceLoading());
    final result = await _getAllServices(const NoParams());
    result.fold<void>(
      (_) => emit(const ServiceLoaded(allServices: [])),
      (services) => emit(ServiceLoaded(allServices: services)),
    );
  }

  Future<void> loadServicesForCustomer(String customerId) async {
    emit(const ServiceLoading());
    final result = await _getServicesByCustomer(customerId);
    result.fold<void>(
      (_) => emit(const ServiceLoaded(allServices: [])),
      (services) => emit(ServiceLoaded(allServices: services)),
    );
  }

  Future<void> addService(ServiceItem service) async {
    final result = await _addService(service);
    result.fold<void>(
      (_) {},
      (saved) {
        if (state is ServiceLoaded) {
          final current = state as ServiceLoaded;
          final List<ServiceItem> updated = [saved, ...current.allServices];
          emit(current.copyWith(allServices: updated));
        } else {
          loadServices();
        }
      },
    );
  }

  Future<void> deleteService(String serviceId) async {
    final result = await _deleteService(serviceId);
    result.fold<void>(
      (_) {},
      (_) {
        if (state is ServiceLoaded) {
          final current = state as ServiceLoaded;
          final List<ServiceItem> updated =
              current.allServices.where((s) => s.id != serviceId).toList();
          emit(current.copyWith(allServices: updated));
        }
      },
    );
  }

  Future<void> updateService(ServiceItem service) async {
    final result = await _updateService(service);
    result.fold<void>(
      (_) {},
      (saved) {
        if (state is ServiceLoaded) {
          final current = state as ServiceLoaded;
          final List<ServiceItem> updated = current.allServices
              .map((s) => s.id == saved.id ? saved : s)
              .toList();
          emit(current.copyWith(allServices: updated));
        } else {
          loadServices();
        }
      },
    );
  }

  void filterByCategory(String? category) {
    if (state is! ServiceLoaded) return;
    final current = state as ServiceLoaded;
    emit(ServiceLoaded(
      allServices: current.allServices,
      selectedCategory: (category == null || category.isEmpty || category == 'All')
          ? null
          : category,
    ));
  }

  List<ServiceItem> getServicesForCustomer(String customerId) {
    if (state is! ServiceLoaded) return [];
    final current = state as ServiceLoaded;
    return current.allServices.where((s) => s.customerId == customerId).toList();
  }
}
