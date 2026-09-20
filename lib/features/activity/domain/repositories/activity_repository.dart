import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../entities/activity.dart';

abstract class ActivityRepository {
  Future<Either<Failure, List<Activity>>> getAllActivities();
  Future<Either<Failure, List<Activity>>> getActivitiesByCustomer(String customerId);
  Future<Either<Failure, Activity>> logActivity(Activity activity);
  Future<Either<Failure, Activity>> updateActivity(Activity activity);
  Future<Either<Failure, void>> deleteActivity(String activityId);
}
