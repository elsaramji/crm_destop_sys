import 'package:equatable/equatable.dart';
import '../../domain/entities/service_item.dart';

abstract class ServiceState extends Equatable {
  const ServiceState();

  @override
  List<Object?> get props => [];
}

class ServiceLoading extends ServiceState {
  const ServiceLoading();
}

class ServiceLoaded extends ServiceState {
  final List<ServiceItem> allServices;
  final String? selectedCategory;

  const ServiceLoaded({
    required this.allServices,
    this.selectedCategory,
  });

  List<ServiceItem> get filteredServices {
    if (selectedCategory == null || selectedCategory!.isEmpty || selectedCategory == 'All') {
      return allServices;
    }
    return allServices.where((s) => s.category == selectedCategory).toList();
  }

  ServiceLoaded copyWith({
    List<ServiceItem>? allServices,
    String? selectedCategory,
    bool clearSelectedCategory = false,
  }) {
    return ServiceLoaded(
      allServices: allServices ?? this.allServices,
      selectedCategory: clearSelectedCategory ? null : (selectedCategory ?? this.selectedCategory),
    );
  }

  @override
  List<Object?> get props => [allServices, selectedCategory];
}
