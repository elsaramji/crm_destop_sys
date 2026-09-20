import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/service_item.dart';
import '../repositories/service_repository.dart';

class UpdateService implements UseCase<ServiceItem, ServiceItem> {
  final ServiceRepository repository;

  UpdateService(this.repository);

  @override
  Future<Either<Failure, ServiceItem>> call(ServiceItem service) {
    return repository.updateService(service);
  }
}
