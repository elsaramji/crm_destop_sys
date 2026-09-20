import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/customer.dart';
import 'customer_form_state.dart';
import 'customer_list_cubit.dart';

class CustomerFormCubit extends Cubit<CustomerFormState> {
  CustomerFormCubit() : super(const CustomerFormState());

  void initForCreate() {
    emit(CustomerFormState(
      id: 'cust_${DateTime.now().millisecondsSinceEpoch}',
      phoneNumbers: const [''],
    ));
  }

  void initForEdit(Customer customer) {
    emit(CustomerFormState(
      id: customer.id,
      nationalId: customer.nationalId,
      fullName: customer.fullName,
      phoneNumbers: List<String>.from(customer.phoneNumbers),
      address: customer.address ?? '',
      email: customer.email ?? '',
      customFields: Map<String, String>.from(customer.customFields),
      isEdit: true,
    ));
  }

  void setNationalId(String val) => emit(state.copyWith(nationalId: val, errorMessage: null));
  void setFullName(String val) => emit(state.copyWith(fullName: val, errorMessage: null));
  void setAddress(String val) => emit(state.copyWith(address: val, errorMessage: null));
  void setEmail(String val) => emit(state.copyWith(email: val, errorMessage: null));

  void addPhoneNumber() {
    final updated = List<String>.from(state.phoneNumbers)..add('');
    emit(state.copyWith(phoneNumbers: updated));
  }

  void updatePhoneNumber(int index, String val) {
    final updated = List<String>.from(state.phoneNumbers);
    if (index >= 0 && index < updated.length) {
      updated[index] = val;
      emit(state.copyWith(phoneNumbers: updated, errorMessage: null));
    }
  }

  void removePhoneNumber(int index) {
    if (state.phoneNumbers.length <= 1) return; // Keep at least one
    final updated = List<String>.from(state.phoneNumbers)..removeAt(index);
    emit(state.copyWith(phoneNumbers: updated));
  }

  void setCustomField(String key, String val) {
    final updated = Map<String, String>.from(state.customFields);
    if (val.trim().isEmpty) {
      updated.remove(key);
    } else {
      updated[key] = val;
    }
    emit(state.copyWith(customFields: updated));
  }

  Future<bool> submit(CustomerListCubit listCubit) async {
    final nationalId = state.nationalId.trim();
    final fullName = state.fullName.trim();
    final validPhones = state.phoneNumbers.map((p) => p.trim()).where((p) => p.isNotEmpty).toList();

    if (fullName.isEmpty) {
      emit(state.copyWith(errorMessage: 'Please enter the customer full name.'));
      return false;
    }

    if (nationalId.isEmpty) {
      emit(state.copyWith(errorMessage: 'Egyptian National ID is required.'));
      return false;
    }

    if (nationalId.length != 14 || !RegExp(r'^[0-9]+$').hasMatch(nationalId)) {
      emit(state.copyWith(errorMessage: 'National ID must be exactly 14 numeric digits.'));
      return false;
    }

    if (validPhones.isEmpty) {
      emit(state.copyWith(errorMessage: 'At least one phone number is required.'));
      return false;
    }

    // Check duplicate National ID
    if (listCubit.isNationalIdDuplicate(nationalId, state.isEdit ? state.id : null)) {
      emit(state.copyWith(errorMessage: 'A customer with this National ID ($nationalId) already exists.'));
      return false;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    await Future.delayed(const Duration(milliseconds: 250));

    final now = DateTime.now();
    final customer = Customer(
      id: state.id,
      nationalId: nationalId,
      fullName: fullName,
      phoneNumbers: validPhones,
      address: state.address.trim().isEmpty ? null : state.address.trim(),
      email: state.email.trim().isEmpty ? null : state.email.trim(),
      customFields: state.customFields,
      createdAt: state.isEdit
          ? (listCubit.getCustomerById(state.id)?.createdAt ?? now)
          : now,
      updatedAt: now,
    );

    final bool success;
    if (state.isEdit) {
      success = await listCubit.updateCustomer(customer);
    } else {
      success = await listCubit.addCustomer(customer);
    }

    if (!success) {
      emit(state.copyWith(isSubmitting: false, errorMessage: 'Failed to save customer to local database.'));
      return false;
    }

    emit(state.copyWith(isSubmitting: false, isSuccess: true));
    return true;
  }
}
