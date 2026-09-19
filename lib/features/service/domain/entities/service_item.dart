import 'package:equatable/equatable.dart';

class ServiceItem extends Equatable {
  final String id;
  final String customerId;
  final String name;
  final String category;
  final double price;
  final DateTime dateProvided;
  final String? notes;

  const ServiceItem({
    required this.id,
    required this.customerId,
    required this.name,
    required this.category,
    required this.price,
    required this.dateProvided,
    this.notes,
  });

  ServiceItem copyWith({
    String? id,
    String? customerId,
    String? name,
    String? category,
    double? price,
    DateTime? dateProvided,
    String? notes,
  }) {
    return ServiceItem(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      dateProvided: dateProvided ?? this.dateProvided,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        name,
        category,
        price,
        dateProvided,
        notes,
      ];
}
