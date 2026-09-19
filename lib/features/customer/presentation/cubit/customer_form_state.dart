import 'package:equatable/equatable.dart';

class CustomerFormState extends Equatable {
  final String id;
  final String nationalId;
  final String fullName;
  final List<String> phoneNumbers;
  final String address;
  final String email;
  final Map<String, String> customFields;
  final bool isEdit;
  final bool isSubmitting;
  final String? errorMessage;
  final bool isSuccess;

  const CustomerFormState({
    this.id = '',
    this.nationalId = '',
    this.fullName = '',
    this.phoneNumbers = const [''],
    this.address = '',
    this.email = '',
    this.customFields = const {},
    this.isEdit = false,
    this.isSubmitting = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  CustomerFormState copyWith({
    String? id,
    String? nationalId,
    String? fullName,
    List<String>? phoneNumbers,
    String? address,
    String? email,
    Map<String, String>? customFields,
    bool? isEdit,
    bool? isSubmitting,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return CustomerFormState(
      id: id ?? this.id,
      nationalId: nationalId ?? this.nationalId,
      fullName: fullName ?? this.fullName,
      phoneNumbers: phoneNumbers ?? this.phoneNumbers,
      address: address ?? this.address,
      email: email ?? this.email,
      customFields: customFields ?? this.customFields,
      isEdit: isEdit ?? this.isEdit,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
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
        isEdit,
        isSubmitting,
        errorMessage,
        isSuccess,
      ];
}
