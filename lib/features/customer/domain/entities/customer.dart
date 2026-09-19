import 'package:equatable/equatable.dart';

class Customer extends Equatable {
  final String id;
  final String nationalId;
  final String fullName;
  final List<String> phoneNumbers;
  final String? address;
  final String? email;
  final Map<String, String> customFields;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Customer({
    required this.id,
    required this.nationalId,
    required this.fullName,
    required this.phoneNumbers,
    this.address,
    this.email,
    this.customFields = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  Customer copyWith({
    String? id,
    String? nationalId,
    String? fullName,
    List<String>? phoneNumbers,
    String? address,
    String? email,
    Map<String, String>? customFields,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Customer(
      id: id ?? this.id,
      nationalId: nationalId ?? this.nationalId,
      fullName: fullName ?? this.fullName,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      address: address ?? this.address,
      email: email ?? this.email,
      customFields: customFields ?? this.customFields,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        nationalId,
        fullName,
        phoneNumbers,
        address,
        email,
        customFields,
        createdAt,
        updatedAt,
      ];
}
