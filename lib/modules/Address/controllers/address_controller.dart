import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:permission_handler/permission_handler.dart';

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

  final RxString selectedType = 'Home'.obs;

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

  void setAddressType(String type) {
    selectedType.value = type;
  }

  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;

      // 1. Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        Get.snackbar("Service Disabled", "Please enable location services in your settings",
            snackPosition: SnackPosition.TOP);
        return;
      }

      // 2. Check and request permission using Geolocator directly (often more reliable on iOS)
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          Get.snackbar("Permission Denied", "Location permission is required to autofill address",
              snackPosition: SnackPosition.TOP);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar("Permission Restricted", "Location permissions are permanently denied. Please enable them in app settings.",
            snackPosition: SnackPosition.TOP,
            mainButton: TextButton(
              onPressed: () => openAppSettings(),
              child: const Text("Settings"),
            ));
        return;
      }

      // 3. Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 4. Get address from coordinates
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];

        // Format street: House number + Street name
        String street = [
          place.name,
          place.subLocality,
          place.thoroughfare
        ].where((e) => e != null && e.isNotEmpty).join(", ");

        streetController.text = street;
        cityController.text = place.locality ?? "";
        stateController.text = place.administrativeArea ?? "";
        countryController.text = place.country ?? "";
        zipCodeController.text = place.postalCode ?? "";
        
        Get.snackbar("Success", "Address fetched from your current location",
            snackPosition: SnackPosition.TOP);
      }
    } catch (e) {
      debugPrint("Location Error: $e");
      Get.snackbar("Error", "Could not fetch location. Please enter manually.",
          snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
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
    selectedType.value = address.type.isNotEmpty ? address.type : 'Home';
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
    selectedType.value = 'Home';
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
        type: selectedType.value,
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
      Get.snackbar('Success', 'Address Updated Successfully', snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createAddress() async {
    try {
      isLoading.value = true;

      final model = AddressModel(
        id: '',
        type: selectedType.value,
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
      Get.snackbar('Success', 'Address Added Successfully', snackPosition: SnackPosition.TOP);
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.TOP);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAddress(String id) async {
    await repository.deleteAddress(id);
    addresses.removeWhere((e) => e.id == id);
  }

  Future<void> setAsDefault(String id) async {
    try {
      final address = addresses.firstWhereOrNull((e) => e.id == id);
      if (address == null) return;

      final model = AddressModel(
        id: address.id,
        type: address.type,
        fullName: address.fullName,
        phone: address.phone,
        street: address.street,
        city: address.city,
        state: address.state,
        country: address.country,
        zipCode: address.zipCode,
        isDefault: true,
      );

      await repository.updateAddress(model);
      await getAddresses();
    } catch (e) {
      Get.snackbar('Error', e.toString(), snackPosition: SnackPosition.TOP);
    }
  }

  String? fullNameValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter full name';
    if (v.length < 3) return 'Full name must be at least 3 characters';
    return null;
  }

  String? phoneValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter phone number';
    if (!RegExp(r'^[0-9]{10,15}$').hasMatch(v)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? streetValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter street address';
    if (v.length < 5) return 'Street address is too short';
    return null;
  }

  String? cityValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter city';
    return null;
  }

  String? stateValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter state';
    return null;
  }

  String? countryValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter country';
    return null;
  }

  String? zipCodeValidator(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Please enter zip code';
    if (v.length < 4) return 'Please enter a valid zip code';
    return null;
  }
}