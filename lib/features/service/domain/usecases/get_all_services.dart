import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/service_item.dart';
import '../repositories/service_repository.dart';

class GetAllServices implements UseCase<List<ServiceItem>, NoParams> {
  final ServiceRepository repository;

  GetAllServices(this.repository);

  @override
  Future<Either<Failure, List<ServiceItem>>> call(NoParams params) {
    return repository.getAllServices();
  }
}
