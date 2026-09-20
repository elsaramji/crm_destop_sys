import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/activity.dart';
import '../repositories/activity_repository.dart';

class UpdateActivity implements UseCase<Activity, Activity> {
  final ActivityRepository repository;

  UpdateActivity(this.repository);

  @override
  Future<Either<Failure, Activity>> call(Activity activity) {
    return repository.updateActivity(activity);
  }
}
