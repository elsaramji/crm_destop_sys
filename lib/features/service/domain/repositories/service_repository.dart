import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/service_item.dart';

abstract class ServiceRepository {
  Future<Either<Failure, List<ServiceItem>>> getAllServices();
  Future<Either<Failure, List<ServiceItem>>> getServicesByCustomer(String customerId);
  Future<Either<Failure, ServiceItem>> addService(ServiceItem service);
  Future<Either<Failure, ServiceItem>> updateService(ServiceItem service);
  Future<Either<Failure, void>> deleteService(String serviceId);
}
