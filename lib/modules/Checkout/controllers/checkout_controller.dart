import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/storage/api_constants.dart';
import '../../../routes/app_routes.dart';
import '../../Address/address_model.dart';
import '../../Address/controllers/address_controller.dart';
import '../../Loader/Helper/Loader_helper.dart';
import '../../Order/controllers/order_history_controller.dart';
import '../../Payment_Summary/Payment_Api_Service.dart';
import '../../Profile & Settings/Setting_Controller/Currency_Controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../cart/controllers/cart_controller.dart';
import '../../../data/Setting_Cont.dart';
import '../coupon_api_service.dart';
import '../coupon_model.dart';

class CheckoutController extends GetxController {
  final CartController cartController = Get.find<CartController>();
  final AddressController addressController = Get.find<AddressController>();
  final AuthController authController = Get.find<AuthController>();
  final CouponApiService couponApiService = CouponApiService();
  final PaymentConfirmationApiService paymentApiService =
  PaymentConfirmationApiService();

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedPaymentMethod = 'bank_transfer'.obs;
  final RxBool isPlacingOrder = false.obs;
  final RxnString selectedAddressId = RxnString();

  // ==================== FORM VALIDATION ====================
  final RxBool isFormValid = false.obs;

  // Error State
  final RxString transactionIdError = ''.obs;
  final RxString bankNameError = ''.obs;
  final RxString transferAmountError = ''.obs;
  final RxString transferDateError = ''.obs;
  final RxString receiptError = ''.obs;

  // Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final transactionIdController = TextEditingController();
  final bankNameController = TextEditingController();
  final transferAmountController = TextEditingController();
  final transferDateController = TextEditingController();
  final streetController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final zipController = TextEditingController();
  final countryController = TextEditingController();
  final couponController = TextEditingController();

  final RxString receiptImagePath = ''.obs;

  // Coupon related
  final RxList<CouponModel> availableCoupons = <CouponModel>[].obs;
  final Rxn<CouponModel> selectedCoupon = Rxn<CouponModel>();
  final Rxn<CouponModel> appliedCoupon = Rxn<CouponModel>();
  final RxString couponError = ''.obs;
  final RxBool isCouponListOpen = false.obs;

  // Getters
  RxList<AddressModel> get savedAddresses => addressController.addresses;
  double get subtotal => cartController.subtotal;
  double get shipping => cartController.shipping;

  double get discountAmount {
    final coupon = appliedCoupon.value;
    if (coupon == null) return 0.0;
    return subtotal * (coupon.discountPercent / 100.0);
  }

  double get total => (subtotal - discountAmount) + shipping;

  CurrencyController? get currencyController =>
      Get.isRegistered<CurrencyController>()
          ? Get.find<CurrencyController>()
          : null;

  String get displayCurrencyCode =>
      currencyController?.selectedCurrency.value ?? 'USD';

  double get displayExchangeRate =>
      currencyController?.selectedRate.value ?? 1.0;

  @override
  void onInit() {
    super.onInit();

    loadCheckoutData();

    // ==================== ADD LISTENERS FOR ALL CONTROLLERS ====================
    final controllers = [
      nameController,
      emailController,
      phoneController,
      streetController,
      cityController,
      stateController,
      zipController,
      countryController,
      transactionIdController,
      bankNameController,
      transferAmountController,
      transferDateController,
    ];

    for (final controller in controllers) {
      controller.addListener(() {
        _validateForm();
        clearFieldErrors();
      });
    }

    // Listen to receipt image changes
    ever(receiptImagePath, (_) {
      _validateForm();
      if (receiptImagePath.value.isNotEmpty) {
        receiptError.value = '';
      }
    });

    // Listen to coupon changes
    ever(appliedCoupon, (_) {
      _validateForm();
    });

    // Initial validation
    _validateForm();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    streetController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipController.dispose();
    countryController.dispose();
    transactionIdController.dispose();
    bankNameController.dispose();
    transferAmountController.dispose();
    transferDateController.dispose();
    couponController.dispose();
    super.onClose();
  }

  // ==================== FORM VALIDATION ====================
  void _validateForm() {
    final bool isValid =
        nameController.text.trim().isNotEmpty &&
            emailController.text.trim().isNotEmpty &&
            phoneController.text.trim().isNotEmpty &&
            streetController.text.trim().isNotEmpty &&
            cityController.text.trim().isNotEmpty &&
            stateController.text.trim().isNotEmpty &&
            zipController.text.trim().isNotEmpty &&
            countryController.text.trim().isNotEmpty &&
            transactionIdController.text.trim().isNotEmpty &&
            bankNameController.text.trim().isNotEmpty &&
            transferAmountController.text.trim().isNotEmpty &&
            transferDateController.text.trim().isNotEmpty &&
            receiptImagePath.value.isNotEmpty;

    isFormValid.value = isValid;
  }

  // ==================== VALIDATE PAYMENT FIELDS ====================
  bool validatePaymentFields() {
    bool isValid = true;

    final transId = transactionIdController.text.trim();
    if (transId.isEmpty) {
      transactionIdError.value = 'Please enter transaction ID';
      isValid = false;
    } else if (transId.length > 100) {
      transactionIdError.value = 'Transaction ID too long';
      isValid = false;
    } else {
      transactionIdError.value = '';
    }

    final bName = bankNameController.text.trim();
    if (bName.isEmpty) {
      bankNameError.value = 'Please enter bank name';
      isValid = false;
    } else if (bName.length > 100) {
      bankNameError.value = 'Bank name too long';
      isValid = false;
    } else {
      bankNameError.value = '';
    }

    if (transferAmountController.text.trim().isEmpty) {
      transferAmountError.value = 'Please enter transfer amount';
      isValid = false;
    } else {
      transferAmountError.value = '';
    }

    if (transferDateController.text.trim().isEmpty) {
      transferDateError.value = 'Please select transfer date';
      isValid = false;
    } else {
      transferDateError.value = '';
    }

    if (receiptImagePath.value.isEmpty) {
      receiptError.value = 'Please upload payment receipt image';
      isValid = false;
    } else {
      receiptError.value = '';
    }

    return isValid;
  }

  void clearFieldErrors() {
    if (transactionIdController.text.trim().isNotEmpty) {
      transactionIdError.value = '';
    }
    if (bankNameController.text.trim().isNotEmpty) {
      bankNameError.value = '';
    }
    if (transferAmountController.text.trim().isNotEmpty) {
      transferAmountError.value = '';
    }
    if (transferDateController.text.trim().isNotEmpty) {
      transferDateError.value = '';
    }
  }

  // ==================== LOAD DATA ====================
  Future<void> loadCheckoutData() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      await Future.wait([
        addressController.getAddresses(),
        fetchProfileData(),
        fetchCouponsFromApi(),
        Get.find<SettingsDataController>().fetchSettings(),
      ]);
      clearShippingFields();
    } catch (e) {
      errorMessage.value = e.toString();
      debugPrint("LOAD CHECKOUT ERROR => $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchProfileData() async {
    if (!authController.authReady.value) {
      await authController.checkLogin();
    }

    if (!authController.isLoggedIn.value) {
      nameController.text = "Guest User";
      emailController.text = "";
      phoneController.text = "";
      return;
    }

    nameController.text = authController.userName ?? "Guest User";
    emailController.text = authController.userEmail ?? "";
    phoneController.text = authController.userMobile ?? "";
  }

  Future<void> fetchCouponsFromApi() async {
    try {
      final response = await couponApiService.fetchAvailableCoupons();
      final data = response['data'];

      if (data is List) {
        final coupons = data
            .whereType<Map>()
            .map((e) => CouponModel.fromJson(Map<String, dynamic>.from(e)))
            .where((e) => e.code.trim().isNotEmpty)
            .toList();
        availableCoupons.assignAll(coupons);
      } else {
        availableCoupons.clear();
      }
    } catch (e) {
      availableCoupons.clear();
      debugPrint("COUPON FETCH ERROR => $e");
    }
  }

  // ==================== ADDRESS ====================
  void onAddressSelected(String? addressId) {
    selectedAddressId.value = addressId;

    if (addressId == null) {
      clearShippingFields();
      _validateForm();
      return;
    }

    final selected = savedAddresses.firstWhereOrNull((e) => e.id == addressId);
    if (selected == null) return;

    streetController.text = selected.street;
    cityController.text = selected.city;
    stateController.text = selected.state;
    zipController.text = selected.zipCode;
    countryController.text = selected.country;

    _validateForm();
  }

  void clearShippingFields() {
    streetController.clear();
    cityController.clear();
    stateController.clear();
    zipController.clear();
    countryController.clear();
    selectedAddressId.value = null;
    _validateForm();
  }

  // ==================== COUPON ====================
  void selectCoupon(CouponModel coupon) {
    selectedCoupon.value = coupon;
    couponError.value = '';
    couponController.text = coupon.code;
    couponController.selection = Selection.fromPosition(
      TextPosition(offset: couponController.text.length),
    );
    isCouponListOpen.value = false;
    _validateForm();
  }

  void applyCouponFromText() {
    isCouponListOpen.value = false;

    final code = couponController.text.trim().toUpperCase();

    if (code.isEmpty) {
      couponError.value = 'Enter coupon code';
      selectedCoupon.value = null;
      appliedCoupon.value = null;
      _validateForm();
      return;
    }

    final coupon = availableCoupons.firstWhereOrNull(
          (e) => e.code.toUpperCase() == code,
    );

    if (coupon == null) {
      couponError.value = 'Invalid coupon code';
      selectedCoupon.value = null;
      appliedCoupon.value = null;
      _validateForm();
      return;
    }

    couponError.value = '';
    selectedCoupon.value = coupon;
    appliedCoupon.value = coupon;

    couponController.text = coupon.code;
    couponController.selection = Selection.fromPosition(
      TextPosition(offset: couponController.text.length),
    );
    _validateForm();
  }

  void removeAppliedCoupon() {
    appliedCoupon.value = null;
    selectedCoupon.value = null;
    couponController.clear();
    couponError.value = '';
    isCouponListOpen.value = false;
    _validateForm();
  }

  void toggleCouponList() {
    isCouponListOpen.toggle();
  }

  // ==================== RECEIPT IMAGE ====================
  Future<void> pickReceiptImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'pdf'],
      );

      if (result != null &&
          result.files.isNotEmpty &&
          result.files.single.path != null) {
        receiptImagePath.value = result.files.single.path!;
        errorMessage.value = '';
        receiptError.value = '';
        _validateForm();
      }
    } catch (e) {
      Get.snackbar(
        "Upload Error",
        "We couldn't select the image. Please try again or check your permissions.",
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // ==================== REFRESH ====================
  Future<void> refreshPage() async {
    await Future.wait([
      loadCheckoutData(),
      cartController.refreshCart(),
    ]);
    _validateForm();
  }
  final imageBaseUrl = ApiConstants.baseUrl.replaceAll("/api/v1", "");
  // ==================== PLACE ORDER ====================
  Future<void> placeOrder() async {
    // Check if already placing order
    if (isPlacingOrder.value) return;

    // Check if form is valid
    final formValid = formKey.currentState?.validate() ?? false;
    final paymentValid = validatePaymentFields();

    if (!formValid || !paymentValid) {
      _validateForm();
      return;
    }

    // Double check - if form is invalid, return
    if (!isFormValid.value) {
      return;
    }

    isPlacingOrder.value = true;

    if (cartController.cartItems.isEmpty) {
      isPlacingOrder.value = false;
      Get.snackbar(
        "Cart Empty",
        "Your shopping cart is empty. Please add items before placing an order.",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    // Build the order payload
    final Map<String, dynamic> payload = {
      "customerName": nameController.text.trim(),
      "customerEmail": emailController.text.trim(),
      "customerPhone": phoneController.text.trim(),
      "shippingAddress": {
        "street": streetController.text.trim(),
        "city": cityController.text.trim(),
        "state": stateController.text.trim(),
        "zipCode": zipController.text.trim(),
        "country": countryController.text.trim(),
      },
      "subtotal": subtotal,
      "items": cartController.cartItems.map((e) {
        return {
          "id": e.id,
          "sku": e.sku,
          "slug": e.diamondData?["slug"],
          "title": e.diamondTitle,
          "shape": e.diamondData?["shape"],
          "carat": e.diamondData?["carat"],
          "color": e.diamondData?["color"],
          "clarity": e.diamondData?["clarity"],
          "cut": e.diamondData?["cut"],
          "certification": e.diamondData?["certification"],
          "price": e.price,
          "priceUsd": e.diamondData?["priceUsd"] ?? e.price,
          "originalPrice": e.diamondData?["originalPrice"],
          "originalPriceUsd": e.diamondData?["originalPriceUsd"],
          "quantity": e.quantity.value,
          "image": e.image
              ?.toString()
              .replaceFirst(
            "http://193.46.198.103",
            imageBaseUrl,
          ),
        };
      }).toList(),
      "total": total,
      "couponCode": appliedCoupon.value?.code ?? '',
      "discountAmount": discountAmount,
      "displayCurrency": displayCurrencyCode,
      "exchangeRate": displayExchangeRate,
      "pricingLocale": "en-US",
      "pricingCountry": "US",
      // Payment proof fields
      "paymentMethod": selectedPaymentMethod.value.toUpperCase(),
      "utrNumber": transactionIdController.text.trim(),
      "bankName": bankNameController.text.trim(),
      "amount": total,
      "transferDate": transferDateController.text.trim(),
    };

    try {
      isLoading.value = true;
      errorMessage.value = '';

      debugPrint("ORDER PAYLOAD => ${jsonEncode(payload)}");
      debugPrint("RECEIPT FILE => ${receiptImagePath.value}");

      final orderResponse = await paymentApiService.placeOrder(
        payload: payload,
        screenshotPath: receiptImagePath.value,
        utrNumber: transactionIdController.text.trim(),
        bankName: bankNameController.text.trim(),
        amount: total.toString(),
        transferDate: transferDateController.text.trim(),
      );

      debugPrint("ORDER RESPONSE => $orderResponse");

      final success = orderResponse['success'] == true;
      if (!success) {
        throw Exception(orderResponse['message']?.toString() ?? 'Order failed');
      }

      final data = orderResponse['data'];
      if (data is! Map<String, dynamic>) {
        throw Exception('Invalid order response');
      }

      final orderId = data['id']?.toString() ?? '';
      final amount = (data['displayTotal'] ?? data['total'] ?? total).toDouble();
      final currency = data['displayCurrency']?.toString() ?? 'USD';

      if (orderId.isEmpty) {
        throw Exception('Order ID missing in response');
      }

      // Clear cart after successful order placement
      await cartController.clearCart();

      // Refresh order history
      if (Get.isRegistered<OrderHistoryController>()) {
        await Get.find<OrderHistoryController>().refreshOrders();
      }

      Get.snackbar(
        "Order Confirmed",
        "Your order has been placed successfully!",
        snackPosition: SnackPosition.TOP,
      );
      await AppNavigator.to(
        AppRoutes.Payment_Summary,
        arguments: {
          'orderId': orderId,
          'amount': amount,
          'currency': currency,
          'bankName': bankNameController.text.trim(),
          'utrNumber': transactionIdController.text.trim(),
          'transferDate': transferDateController.text.trim(),
          'status': 'pending',
        },
      );

      isPlacingOrder.value = false;
    } catch (e) {
      isPlacingOrder.value = false;
      errorMessage.value = e.toString();
      Get.snackbar(
        "Order Failed",
        "We couldn't process your order. Please check your details and try again.",
        snackPosition: SnackPosition.TOP,
      );
      debugPrint("PLACE ORDER ERROR => $e");
    } finally {
      isLoading.value = false;
    }
  }
}

// ==================== EXTENSION ====================
extension FirstWhereOrNullExt<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

// ==================== SELECTION EXTENSION ====================
extension Selection on TextEditingController {
  static TextSelection fromPosition(TextPosition position) {
    return TextSelection.fromPosition(position);
  }
}
