import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../address_model.dart';
import '../address_repository.dart';

class AddressController extends GetxController {
  final AddressRepository repository;
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  AddressController(this.repository);

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final Rxn<AddressModel> editingAddress = Rxn<AddressModel>();

  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();
  final zipCodeController = TextEditingController();

  final RxBool isDefault = false.obs;

  @override
  void onInit() {
    super.onInit();
    getAddresses();
  }

  @override
  void onClose() {
    fullNameController.dispose();
    phoneController.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    countryController.dispose();
    zipCodeController.dispose();
    super.onClose();
  }

  Future<void> getAddresses() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final result = await repository.getAddresses();
      addresses.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  void fillForm(AddressModel address) {
    editingAddress.value = address;
    fullNameController.text = address.fullName;
    phoneController.text = address.phone;
    streetController.text = address.street;
    cityController.text = address.city;
    stateController.text = address.state;
    countryController.text = address.country;
    zipCodeController.text = address.zipCode;
    isDefault.value = address.isDefault;
  }

  void clearForm() {
    editingAddress.value = null;
    fullNameController.clear();
    phoneController.clear();
    streetController.clear();
    cityController.clear();
    stateController.clear();
    countryController.clear();
    zipCodeController.clear();
    formKey.currentState?.reset();
    isDefault.value = false;
  }

  Future<void> saveAddress() async {
    final formState = formKey.currentState;
    if (formState == null || !formState.validate()) return;

    if (editingAddress.value == null) {
      await createAddress();
    } else {
      await updateAddress();
    }
  }

  Future<void> updateAddress() async {
    if (editingAddress.value == null) return;

    try {
      isLoading.value = true;

      final model = AddressModel(
        id: editingAddress.value!.id,
        type: 'shipping',
        fullName: fullNameController.text.trim(),
        phone: phoneController.text.trim(),
        street: streetController.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        country: countryController.text.trim(),
        zipCode: zipCodeController.text.trim(),
        isDefault: isDefault.value,
      );

      await repository.updateAddress(model);
      await getAddresses();
      clearForm();
      Get.back();
      Get.snackbar('Success', 'Address Updated Successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createAddress() async {
    try {
      isLoading.value = true;

      final model = AddressModel(
        id: '',
        type: 'shipping',
        fullName: fullNameController.text.trim(),
        phone: phoneController.text.trim(),
        street: streetController.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        country: countryController.text.trim(),
        zipCode: zipCodeController.text.trim(),
        isDefault: isDefault.value,
      );

      await repository.createAddress(model);
      await getAddresses();
      clearForm();
      Get.back();
      Get.snackbar('Success', 'Address Added Successfully');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAddress(String id) async {
    await repository.deleteAddress(id);
    addresses.removeWhere((e) => e.id == id);
  }

  String? fullNameValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your full name';
    if (v.length < 3) return 'Full name must be at least 3 characters';
    return null;
  }

  String? phoneValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your phone number';
    if (!RegExp(r'^[0-9]{10,15}$').hasMatch(v)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? streetValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your street address';
    if (v.length < 5) return 'Street address is too short';
    return null;
  }

  String? cityValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your city';
    return null;
  }

  String? stateValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your state';
    return null;
  }

  String? countryValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your country';
    return null;
  }

  String? zipCodeValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter your zip code';
    if (v.length < 4) return 'Please enter a valid zip code';
    return null;
  }
}