import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/mock/mock_data.dart';
import '../../domain/entities/activity.dart';
import 'activity_state.dart';

class ActivityCubit extends Cubit<ActivityState> {
  ActivityCubit() : super(const ActivityLoading()) {
    loadActivities();
  }

  void loadActivities() {
    emit(ActivityLoaded(
      allActivities: List<Activity>.from(MockData.initialActivities),
    ));
  }

  void logActivity(Activity activity) {
    if (state is! ActivityLoaded) return;
    final current = state as ActivityLoaded;
    final updated = [activity, ...current.allActivities];
    emit(current.copyWith(allActivities: updated));
  }

  void updateActivity(Activity activity) {
    if (state is! ActivityLoaded) return;
    final current = state as ActivityLoaded;
    final updated = current.allActivities.map((a) => a.id == activity.id ? activity : a).toList();
    emit(current.copyWith(allActivities: updated));
  }

  void deleteActivity(String activityId) {
    if (state is! ActivityLoaded) return;
    final current = state as ActivityLoaded;
    final updated = current.allActivities.where((a) => a.id != activityId).toList();
    emit(current.copyWith(allActivities: updated));
  }

  void filterByType(ActivityType? type) {
    if (state is! ActivityLoaded) return;
    final current = state as ActivityLoaded;
    emit(ActivityLoaded(
      allActivities: current.allActivities,
      selectedType: (type == ActivityType.all) ? null : type,
    ));
  }

  List<Activity> getActivitiesForCustomer(String customerId) {
    if (state is! ActivityLoaded) return [];
    final current = state as ActivityLoaded;
    final list = current.allActivities.where((a) => a.customerId == customerId).toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }
}
