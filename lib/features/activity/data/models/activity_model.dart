import '../../../../core/database/app_database.dart';
import '../../domain/entities/activity.dart';

class ActivityModel {
  static Activity fromDrift(ActivitiesTableData row) {
    return Activity(
      id: row.id,
      customerId: row.customerId,
      type: ActivityType.fromString(row.type),
      note: row.note,
      timestamp: row.timestamp,
    );
  }

  static ActivitiesTableCompanion toCompanion(Activity activity) {
    return ActivitiesTableCompanion.insert(
      id: activity.id,
      customerId: activity.customerId,
      type: activity.type.name,
      note: activity.note,
      timestamp: activity.timestamp,
    );
  }
}
