import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/service_repository.dart';

class DeleteService implements UseCase<void, String> {
  final ServiceRepository repository;

  DeleteService(this.repository);

  @override
  Future<Either<Failure, void>> call(String serviceId) {
    return repository.deleteService(serviceId);
  }
}
