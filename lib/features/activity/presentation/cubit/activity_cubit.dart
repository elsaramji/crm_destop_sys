import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fpdart/fpdart.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/activity.dart';
import '../../domain/usecases/delete_activity.dart';
import '../../domain/usecases/get_activities_by_customer.dart';
import '../../domain/usecases/get_all_activities.dart';
import '../../domain/usecases/log_activity.dart';
import '../../domain/usecases/update_activity.dart';
import 'activity_state.dart';

class ActivityCubit extends Cubit<ActivityState> {
  final GetAllActivities _getAllActivities;
  final GetActivitiesByCustomer _getActivitiesByCustomer;
  final LogActivity _logActivity;
  final UpdateActivity _updateActivity;
  final DeleteActivity _deleteActivity;

  ActivityCubit({
    required GetAllActivities getAllActivities,
    required GetActivitiesByCustomer getActivitiesByCustomer,
    required LogActivity logActivity,
    required UpdateActivity updateActivity,
    required DeleteActivity deleteActivity,
  })  : _getAllActivities = getAllActivities,
        _getActivitiesByCustomer = getActivitiesByCustomer,
        _logActivity = logActivity,
        _updateActivity = updateActivity,
        _deleteActivity = deleteActivity,
        super(const ActivityLoading()) {
    loadActivities();
  }

  Future<void> loadActivities() async {
    emit(const ActivityLoading());
    final result = await _getAllActivities(const NoParams());
    result.fold<void>(
      (_) => emit(const ActivityLoaded(allActivities: [])),
      (activities) => emit(ActivityLoaded(allActivities: activities)),
    );
  }

  Future<void> loadActivitiesForCustomer(String customerId) async {
    emit(const ActivityLoading());
    final result = await _getActivitiesByCustomer(customerId);
    result.fold<void>(
      (_) => emit(const ActivityLoaded(allActivities: [])),
      (activities) => emit(ActivityLoaded(allActivities: activities)),
    );
  }

  Future<void> logActivity(Activity activity) async {
    final result = await _logActivity(activity);
    result.fold<void>(
      (_) {},
      (saved) {
        if (state is ActivityLoaded) {
          final current = state as ActivityLoaded;
          final List<Activity> updated = [saved, ...current.allActivities];
          emit(current.copyWith(allActivities: updated));
        } else {
          loadActivities();
        }
      },
    );
  }

  Future<void> updateActivity(Activity activity) async {
    final result = await _updateActivity(activity);
    result.fold<void>(
      (_) {},
      (saved) {
        if (state is ActivityLoaded) {
          final current = state as ActivityLoaded;
          final List<Activity> updated = current.allActivities
              .map((a) => a.id == saved.id ? saved : a)
              .toList();
          emit(current.copyWith(allActivities: updated));
        } else {
          loadActivities();
        }
      },
    );
  }

  Future<void> deleteActivity(String activityId) async {
    final result = await _deleteActivity(activityId);
    result.fold<void>(
      (_) {},
      (_) {
        if (state is ActivityLoaded) {
          final current = state as ActivityLoaded;
          final List<Activity> updated =
              current.allActivities.where((a) => a.id != activityId).toList();
          emit(current.copyWith(allActivities: updated));
        }
      },
    );
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
    final list = current.allActivities
        .where((a) => a.customerId == customerId)
        .toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }
}
