import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/service_item.dart';

class ServiceModel {
  static ServiceItem fromDrift(ServicesTableData row) {
    return ServiceItem(
      id: row.id,
      customerId: row.customerId,
      name: row.name,
      category: row.category,
      price: row.price,
      dateProvided: row.dateProvided,
      notes: row.notes,
    );
  }

  static ServicesTableCompanion toCompanion(ServiceItem service) {
    return ServicesTableCompanion.insert(
      id: service.id,
      customerId: service.customerId,
      name: service.name,
      category: service.category,
      price: service.price,
      dateProvided: service.dateProvided,
      notes: Value(service.notes),
    );
  }
}
