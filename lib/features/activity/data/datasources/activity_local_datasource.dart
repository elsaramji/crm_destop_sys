import 'package:drift/drift.dart';
import '../../../../core/database/app_database.dart';
import '../../domain/entities/activity.dart';
import '../models/activity_model.dart';

abstract class ActivityLocalDatasource {
  Future<List<Activity>> getAllActivities();
  Future<List<Activity>> getActivitiesByCustomer(String customerId);
  Future<Activity> logActivity(Activity activity);
  Future<Activity> updateActivity(Activity activity);
  Future<void> deleteActivity(String activityId);
}

class ActivityLocalDatasourceImpl implements ActivityLocalDatasource {
  final AppDatabase database;

  ActivityLocalDatasourceImpl(this.database);

  @override
  Future<List<Activity>> getAllActivities() async {
    final rows = await (database.select(database.activitiesTable)
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
    return rows.map(ActivityModel.fromDrift).toList();
  }

  @override
  Future<List<Activity>> getActivitiesByCustomer(String customerId) async {
    final rows = await (database.select(database.activitiesTable)
          ..where((t) => t.customerId.equals(customerId))
          ..orderBy([(t) => OrderingTerm.desc(t.timestamp)]))
        .get();
    return rows.map(ActivityModel.fromDrift).toList();
  }

  @override
  Future<Activity> logActivity(Activity activity) async {
    await database.into(database.activitiesTable).insert(ActivityModel.toCompanion(activity));
    return activity;
  }

  @override
  Future<Activity> updateActivity(Activity activity) async {
    await (database.update(database.activitiesTable)
          ..where((t) => t.id.equals(activity.id)))
        .write(ActivityModel.toCompanion(activity));
    return activity;
  }

  @override
  Future<void> deleteActivity(String activityId) async {
    await (database.delete(database.activitiesTable)..where((t) => t.id.equals(activityId))).go();
  }
}
