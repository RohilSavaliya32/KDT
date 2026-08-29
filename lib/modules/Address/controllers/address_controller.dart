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

  // =========================
  // Loading / Error
  // =========================

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // =========================
  // Address Data
  // =========================

  final RxList<AddressModel> addresses = <AddressModel>[].obs;
  final Rxn<AddressModel> editingAddress = Rxn<AddressModel>();

  // =========================
  // Controllers
  // =========================

  final fullNameController = TextEditingController();
  final phoneController = TextEditingController();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final countryController = TextEditingController();
  final zipCodeController = TextEditingController();

  // =========================
  // Validation
  // =========================

  final RxString phoneError = ''.obs;

  // =========================
  // Address Options
  // =========================

  final RxBool isDefault = false.obs;

  final RxString selectedType = 'Home'.obs;
  final RxString selectedCountryCode = '+91'.obs;
  final RxString selectedCountryFlag = '🇮🇳'.obs;
  final RxString selectedCountryIso = 'IN'.obs;

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

  // =========================
  // Address Type
  // =========================

  void setAddressType(String type) {
    selectedType.value = type;
  }

  // =========================
  // Current Location
  // =========================

  Future<void> getCurrentLocation() async {
    try {
      isLoading.value = true;

      // 1. Check location service
      final bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        Get.snackbar(
          "Location Services Disabled",
          "Please enable location services in your device settings to use this feature.",
          snackPosition: SnackPosition.TOP,
        );

        return;
      }

      // 2. Check permission
      LocationPermission permission =
      await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          Get.snackbar(
            "Location Permission Denied",
            "Location access is required to automatically fill your address details.",
            snackPosition: SnackPosition.TOP,
          );

          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        Get.snackbar(
          "Location Access Restricted",
          "Location permissions are permanently denied. Please enable them in your app settings.",
          snackPosition: SnackPosition.TOP,
          mainButton: TextButton(
            onPressed: () => openAppSettings(),
            child: const Text("Settings"),
          ),
        );

        return;
      }

      // 3. Get current position
      final Position position =
      await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // 4. Reverse geocode
      final List<Placemark> placemarks =
      await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks[0];

        final String street = [
          place.name,
          place.subLocality,
          place.thoroughfare,
        ]
            .where((e) => e != null && e.isNotEmpty)
            .join(", ");

        streetController.text = street;
        cityController.text = place.locality ?? "";
        stateController.text =
            place.administrativeArea ?? "";
        countryController.text = place.country ?? "";
        zipCodeController.text = place.postalCode ?? "";
      }
    } catch (e) {
      debugPrint("Location Error: $e");

      Get.snackbar(
        "Location Error",
        "We couldn't fetch your current location. Please enter the details manually.",
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // Get Addresses
  // =========================

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

  // =========================
  // Fill Form - Edit
  // =========================

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

    selectedType.value =
    address.type.isNotEmpty ? address.type : 'Home';

    // Clear old validation error
    phoneError.value = '';
  }

  // =========================
  // Clear Form
  // =========================

  void clearForm() {
    editingAddress.value = null;

    fullNameController.clear();
    phoneController.clear();
    streetController.clear();
    cityController.clear();
    stateController.clear();
    countryController.clear();
    zipCodeController.clear();

    phoneError.value = '';

    formKey.currentState?.reset();

    isDefault.value = false;

    selectedType.value = 'Home';

    selectedCountryCode.value = '+91';
    selectedCountryFlag.value = '🇮🇳';
    selectedCountryIso.value = 'IN';
  }

  // =========================
  // SAVE ADDRESS
  // =========================

  Future<void> saveAddress() async {
    if (isLoading.value) return;

    final formState = formKey.currentState;

    if (formState == null) return;

    // -------------------------
    // Validate normal fields
    // -------------------------

    final bool isValid = formState.validate();

    // -------------------------
    // Validate phone manually
    // -------------------------

    final String phone = phoneController.text.trim();

    if (phone.isEmpty) {
      phoneError.value = 'Please enter your phone number';

      // Make other form fields show their errors
      formState.validate();

      return;
    }

    final String? phoneValidationError =
    phoneValidator(phone);

    if (phoneValidationError != null) {
      phoneError.value = phoneValidationError;

      formState.validate();

      return;
    }

    // Phone is valid
    phoneError.value = '';

    // Stop if any normal field is invalid
    if (!isValid) {
      return;
    }

    // -------------------------
    // Create / Update
    // -------------------------

    if (editingAddress.value == null) {
      await createAddress();
    } else {
      await updateAddress();
    }
  }

  // =========================
  // UPDATE ADDRESS
  // =========================

  Future<void> updateAddress() async {
    if (editingAddress.value == null) return;

    // Double safety validation
    final String phone = phoneController.text.trim();

    if (phone.isEmpty) {
      phoneError.value = 'Please enter your phone number';
      return;
    }

    final String? phoneValidationError =
    phoneValidator(phone);

    if (phoneValidationError != null) {
      phoneError.value = phoneValidationError;
      return;
    }

    try {
      isLoading.value = true;

      final model = AddressModel(
        id: editingAddress.value!.id,
        type: selectedType.value,
        fullName: fullNameController.text.trim(),
        phone:
        "${selectedCountryCode.value}${phoneController.text.trim()}",
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

      Get.snackbar(
        'Address Updated',
        'Your address changes have been saved successfully.',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Update Failed',
        'We couldn’t save your changes. Please check your connection and try again.',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // CREATE ADDRESS
  // =========================

  Future<void> createAddress() async {
    // Double safety validation
    final String phone = phoneController.text.trim();

    if (phone.isEmpty) {
      phoneError.value = 'Please enter your phone number';
      return;
    }

    final String? phoneValidationError =
    phoneValidator(phone);

    if (phoneValidationError != null) {
      phoneError.value = phoneValidationError;
      return;
    }

    try {
      isLoading.value = true;

      final model = AddressModel(
        id: '',
        type: selectedType.value,
        fullName: fullNameController.text.trim(),
        phone:
        "${selectedCountryCode.value}${phoneController.text.trim()}",
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

      Get.snackbar(
        'Address Added',
        'Your new delivery address has been saved successfully.',
        snackPosition: SnackPosition.TOP,
      );
    } catch (e) {
      Get.snackbar(
        'Address Failed',
        'We couldn’t save your address. Please try again later.',
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // =========================
  // DELETE ADDRESS
  // =========================

  Future<void> deleteAddress(String id) async {
    await repository.deleteAddress(id);

    addresses.removeWhere(
          (e) => e.id == id,
    );
  }

  // =========================
  // SET DEFAULT
  // =========================

  Future<void> setAsDefault(String id) async {
    try {
      final address =
      addresses.firstWhereOrNull((e) => e.id == id);

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
      Get.snackbar(
        'Operation Failed',
        'Could not set this address as default. Please try again.',
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // =========================
  // VALIDATORS
  // =========================

  String? fullNameValidator(String? value) {
    final v = value?.trim() ?? '';

    if (v.isEmpty) {
      return 'Please enter your full name';
    }

    if (v.length < 3) {
      return 'Name must be at least 3 characters long';
    }

    return null;
  }

  String? phoneValidator(String? value) {
    final v = value?.trim() ?? '';

    if (v.isEmpty) {
      return 'Please enter your phone number';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(v)) {
      return 'Phone number must contain only digits';
    }

    if (v.length < 10 || v.length > 12) {
      return 'Please enter a valid 10-12 digit phone number';
    }

    return null;
  }

  String? streetValidator(String? value) {
    final v = value?.trim() ?? '';

    if (v.isEmpty) {
      return 'Please enter your detailed address';
    }

    if (v.length < 5) {
      return 'Please enter a more detailed address';
    }

    return null;
  }

  String? cityValidator(String? value) {
    final v = value?.trim() ?? '';

    if (v.isEmpty) {
      return 'Please enter your city';
    }

    return null;
  }

  String? stateValidator(String? value) {
    final v = value?.trim() ?? '';

    if (v.isEmpty) {
      return 'Please enter your state';
    }

    return null;
  }

  String? countryValidator(String? value) {
    final v = value?.trim() ?? '';

    if (v.isEmpty) {
      return 'Please enter your country';
    }

    return null;
  }

  String? zipCodeValidator(String? value) {
    final v = value?.trim() ?? '';

    if (v.isEmpty) {
      return 'Please enter your pincode';
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(v)) {
      return 'Pincode must contain only digits';
    }

    if (v.length < 4 || v.length > 8) {
      return 'Please enter a valid pincode';
    }

    return null;
  }
}