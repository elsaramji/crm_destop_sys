import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/service_item.dart';
import '../models/service_model.dart';

abstract class ServiceLocalDatasource {
  Future<List<ServiceItem>> getAllServices();
  Future<List<ServiceItem>> getServicesByCustomer(String customerId);
  Future<ServiceItem> addService(ServiceItem service);
  Future<ServiceItem> updateService(ServiceItem service);
  Future<void> deleteService(String serviceId);
}

class ServiceLocalDatasourceImpl implements ServiceLocalDatasource {
  final AppDatabase database;

  ServiceLocalDatasourceImpl(this.database);

  @override
  Future<List<ServiceItem>> getAllServices() async {
    final rows = await (database.select(database.servicesTable)
          ..orderBy([(t) => OrderingTerm.desc(t.dateProvided)]))
        .get();
    return rows.map(ServiceModel.fromDrift).toList();
  }

  @override
  Future<List<ServiceItem>> getServicesByCustomer(String customerId) async {
    final rows = await (database.select(database.servicesTable)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm.desc(t.dateProvided)]))
        .get();
    return rows.map(ServiceModel.fromDrift).toList();
  }

  @override
  Future<ServiceItem> addService(ServiceItem service) async {
    await database.into(database.servicesTable).insert(ServiceModel.toCompanion(service));
    return service;
  }

  @override
  Future<ServiceItem> updateService(ServiceItem service) async {
    await (database.update(database.servicesTable)
          ..where((t) => t.id.equals(service.id)))
        .write(ServiceModel.toCompanion(service));
    return service;
  }

  @override
  Future<void> deleteService(String serviceId) async {
    await (database.delete(database.servicesTable)..where((t) => t.id.equals(serviceId))).go();
  }
}
