import 'package:equatable/equatable.dart';
import '../../domain/entities/activity.dart';

abstract class ActivityState extends Equatable {
  const ActivityState();

  @override
  List<Object?> get props => [];
}

class ActivityLoading extends ActivityState {
  const ActivityLoading();
}

class ActivityLoaded extends ActivityState {
  final List<Activity> allActivities;
  final ActivityType? selectedType;

  const ActivityLoaded({
    required this.allActivities,
    this.selectedType,
  });

  List<Activity> get sortedActivities {
    final list = (selectedType == null || selectedType == ActivityType.all)
        ? List<Activity>.from(allActivities)
        : allActivities.where((a) => a.type == selectedType).toList();
    list.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return list;
  }

  ActivityLoaded copyWith({
    List<Activity>? allActivities,
    ActivityType? selectedType,
    bool clearSelectedType = false,
  }) {
    return ActivityLoaded(
      allActivities: allActivities ?? this.allActivities,
      selectedType: clearSelectedType ? null : (selectedType ?? this.selectedType),
    );
  }

  @override
  List<Object?> get props => [allActivities, selectedType];
}
