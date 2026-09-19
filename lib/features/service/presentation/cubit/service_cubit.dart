import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/mock/mock_data.dart';
import '../../domain/entities/service_item.dart';
import 'service_state.dart';

class ServiceCubit extends Cubit<ServiceState> {
  ServiceCubit() : super(const ServiceLoading()) {
    loadServices();
  }

  void loadServices() {
    emit(ServiceLoaded(
      allServices: List<ServiceItem>.from(MockData.initialServices),
    ));
  }

  void addService(ServiceItem service) {
    if (state is! ServiceLoaded) return;
    final current = state as ServiceLoaded;
    final updated = [service, ...current.allServices];
    emit(current.copyWith(allServices: updated));
  }

  void deleteService(String serviceId) {
    if (state is! ServiceLoaded) return;
    final current = state as ServiceLoaded;
    final updated = current.allServices.where((s) => s.id != serviceId).toList();
    emit(current.copyWith(allServices: updated));
  }

  void updateService(ServiceItem service) {
    if (state is! ServiceLoaded) return;
    final current = state as ServiceLoaded;
    final updated = current.allServices.map((s) => s.id == service.id ? service : s).toList();
    emit(current.copyWith(allServices: updated));
  }

  void filterByCategory(String? category) {
    if (state is! ServiceLoaded) return;
    final current = state as ServiceLoaded;
    emit(current.copyWith(selectedCategory: category));
  }

  List<ServiceItem> getServicesForCustomer(String customerId) {
    if (state is! ServiceLoaded) return [];
    final current = state as ServiceLoaded;
    return current.allServices.where((s) => s.customerId == customerId).toList();
  }
}
