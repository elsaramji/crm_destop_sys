import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/activity.dart';
import '../repositories/activity_repository.dart';

class GetActivitiesByCustomer implements UseCase<List<Activity>, String> {
  final ActivityRepository repository;

  GetActivitiesByCustomer(this.repository);

  @override
  Future<Either<Failure, List<Activity>>> call(String customerId) {
    return repository.getActivitiesByCustomer(customerId);
  }
}
