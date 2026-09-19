import 'package:equatable/equatable.dart';

enum ActivityType {
  call('Call'),
  visit('Visit'),
  complaint('Complaint'),
  followUp('Follow-up'),
  other('Other');

  final String displayName;
  const ActivityType(this.displayName);

  static ActivityType fromString(String value) {
    return ActivityType.values.firstWhere(
      (e) => e.displayName.toLowerCase() == value.toLowerCase() || e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => ActivityType.other,
    );
  }
}

class Activity extends Equatable {
  final String id;
  final String customerId;
  final ActivityType type;
  final String note;
  final DateTime timestamp;

  const Activity({
    required this.id,
    required this.customerId,
    required this.type,
    required this.note,
    required this.timestamp,
  });

  Activity copyWith({
    String? id,
    String? customerId,
    ActivityType? type,
    String? note,
    DateTime? timestamp,
  }) {
    return Activity(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      type: type ?? this.type,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        type,
        note,
        timestamp,
      ];
}
