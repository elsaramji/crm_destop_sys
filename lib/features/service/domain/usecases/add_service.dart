import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/service_item.dart';
import '../repositories/service_repository.dart';

class AddService implements UseCase<ServiceItem, ServiceItem> {
  final ServiceRepository repository;

  AddService(this.repository);

  @override
  Future<Either<Failure, ServiceItem>> call(ServiceItem service) {
    return repository.addService(service);
  }
}
