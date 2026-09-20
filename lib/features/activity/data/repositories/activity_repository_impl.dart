import 'package:fpdart/fpdart.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/activity.dart';
import '../../domain/repositories/activity_repository.dart';
import '../datasources/activity_local_datasource.dart';

class ActivityRepositoryImpl implements ActivityRepository {
  final ActivityLocalDatasource localDatasource;

  ActivityRepositoryImpl(this.localDatasource);

  @override
  Future<Either<Failure, List<Activity>>> getAllActivities() async {
    try {
      final items = await localDatasource.getAllActivities();
      return Right(items);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Activity>>> getActivitiesByCustomer(String customerId) async {
    try {
      final items = await localDatasource.getActivitiesByCustomer(customerId);
      return Right(items);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Activity>> logActivity(Activity activity) async {
    try {
      final created = await localDatasource.logActivity(activity);
      return Right(created);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Activity>> updateActivity(Activity activity) async {
    try {
      final updated = await localDatasource.updateActivity(activity);
      return Right(updated);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteActivity(String activityId) async {
    try {
      await localDatasource.deleteActivity(activityId);
      return const Right(null);
    } catch (e) {
      return Left(DatabaseFailure(e.toString()));
    }
  }
}
