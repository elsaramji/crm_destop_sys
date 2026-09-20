import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/service_item.dart';
import '../repositories/service_repository.dart';

class GetServicesByCustomer implements UseCase<List<ServiceItem>, String> {
  final ServiceRepository repository;

  GetServicesByCustomer(this.repository);

  @override
  Future<Either<Failure, List<ServiceItem>>> call(String customerId) {
    return repository.getServicesByCustomer(customerId);
  }
}
