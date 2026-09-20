import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/activity.dart';
import '../repositories/activity_repository.dart';

class GetAllActivities implements UseCase<List<Activity>, NoParams> {
  final ActivityRepository repository;

  GetAllActivities(this.repository);

  @override
  Future<Either<Failure, List<Activity>>> call(NoParams params) {
    return repository.getAllActivities();
  }
}
