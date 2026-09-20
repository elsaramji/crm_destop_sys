import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/service_item.dart';
import '../../domain/repositories/service_repository.dart';
import '../datasources/service_local_datasource.dart';

class ServiceRepositoryImpl implements ServiceRepository {
  final ServiceLocalDatasource localDatasource;

  ServiceRepositoryImpl(this.localDatasource);

  @override
  Future<Either<Failure, List<ServiceItem>>> getAllServices() async {
    try {
      final items = await localDatasource.getAllServices();
      return Right(items);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ServiceItem>>> getServicesByCustomer(String customerId) async {
    try {
      final items = await localDatasource.getServicesByCustomer(customerId);
      return Right(items);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServiceItem>> addService(ServiceItem service) async {
    try {
      final created = await localDatasource.addService(service);
      return Right(created);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, ServiceItem>> updateService(ServiceItem service) async {
    try {
      final updated = await localDatasource.updateService(service);
      return Right(updated);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteService(String serviceId) async {
    try {
      await localDatasource.deleteService(serviceId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
