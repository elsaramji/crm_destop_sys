import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../repositories/activity_repository.dart';

class DeleteActivity implements UseCase<void, String> {
  final ActivityRepository repository;

  DeleteActivity(this.repository);

  @override
  Future<Either<Failure, void>> call(String activityId) {
    return repository.deleteActivity(activityId);
  }
}
