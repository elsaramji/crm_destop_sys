import 'package:equatable/equatable.dart';

enum OrderStatus {
  pending('Pending'),
  inProgress('In Progress'),
  completed('Completed'),
  cancelled('Cancelled');

  final String displayName;
  const OrderStatus(this.displayName);

  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (e) =>
          e.displayName.toLowerCase() == value.toLowerCase() ||
          e.name.toLowerCase() == value.toLowerCase(),
      orElse: () => OrderStatus.pending,
    );
  }
}

class Orders extends Equatable {
  final String id;
  final String customerId;
  final List<String> items;
  final OrderStatus status;
  final double totalAmount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Orders({
    required this.id,
    required this.customerId,
    required this.items,
    required this.status,
    required this.totalAmount,
    required this.createdAt,
    required this.updatedAt,
  });

  Orders copyWith({
    String? id,
    String? customerId,
    List<String>? items,
    OrderStatus? status,
    double? totalAmount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Orders(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      items: items ?? this.items,
      status: status ?? this.status,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    customerId,
    items,
    status,
    totalAmount,
    createdAt,
    updatedAt,
  ];
}
