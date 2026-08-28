import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';

import '../../Profile & Settings/Setting_Controller/Currency_Controller.dart';
import '../../Profile & Settings/currency_helper.dart';
import '../../auth/controllers/auth_controller.dart';
import '../cart_api_service.dart';

class CartItemModel {
  final dynamic id;
  final dynamic sku;
  final dynamic diamondTitle;
  final dynamic color;
  final dynamic clarity;
  final dynamic cut;
  final dynamic subtitle;
  final dynamic price;
  final dynamic image;
  final Map<String, dynamic>? diamondData;
  final RxInt quantity;
  final int availableQuantity;

  CartItemModel({
    required this.id,
    required this.sku,
    required this.diamondTitle,
    required this.color,
    required this.clarity,
    required this.cut,
    required this.subtitle,
    required this.price,
    required this.image,
    this.diamondData,
    required this.availableQuantity,
    int initialQty = 1,
  }) : quantity = initialQty.obs;
  factory CartItemModel.fromDiamond(
      Map<String, dynamic> diamond, {
        int initialQty = 1,
      }) {
    return CartItemModel(
      id: diamond["id"],
      sku: diamond["sku"],
      diamondTitle: diamond["title"] ?? diamond["name"] ?? '',
      color: diamond["color"] ?? '',
      clarity: diamond["clarity"] ?? '',
      cut: diamond["cut"] ?? '',
      subtitle:
      "${diamond["color"] ?? ''} Color • "
          "${diamond["clarity"] ?? ''} Clarity • "
          "${diamond["cut"] ?? ''} Cut",
      price: diamond["price"] ?? 0,
      image: diamond["image"] ?? '',
      diamondData: Map<String, dynamic>.from(diamond),
      availableQuantity: diamond["quantity"] ?? 0,
      initialQty: initialQty,
    );
  }

  double get itemPrice => double.tryParse(price.toString()) ?? 0.0;
  final formKey = GlobalKey<FormState>();
  final RxBool submitted = false.obs;
  double get totalPrice => itemPrice * quantity.value;

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "sku": sku,
      "diamondTitle": diamondTitle,
      "subtitle": subtitle,
      "price": price,
      "image": image,
      "quantity": quantity.value,
      if (diamondData != null) "diamond": diamondData,
    };
  }

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    final diamond = json["diamond"] is Map
        ? Map<String, dynamic>.from(json["diamond"])
        : null;

    return CartItemModel(
      id: diamond?["id"] ?? json["id"],
      sku: diamond?["sku"] ?? json["sku"],
      diamondTitle: diamond?["title"] ?? json["diamondTitle"] ?? json["Diamond_title"] ?? json["title"] ?? '',
      color: diamond?["color"] ?? json["color"] ?? '',
      clarity: diamond?["clarity"] ?? json["clarity"] ?? '',
      cut: diamond?["cut"] ?? json["cut"] ?? '',
      subtitle: "${diamond?["color"] ?? ''} Color • ""${diamond?["clarity"] ?? ''} Clarity • ""${diamond?["cut"] ?? ''} Cut",
      price: diamond?["price"] ?? json["price"] ?? 0,
      image: diamond?["image"] ?? json["image"] ?? '',
      diamondData: diamond,
      availableQuantity: diamond?["quantity"] ?? json["availableQuantity"] ?? 0,
      initialQty: json["quantity"] ?? 1,
    );
  }}

class CartController extends GetxController {
  final AuthController auth = Get.find<AuthController>();
  final GetStorage box = GetStorage();
  final CartApiService api = CartApiService();

  final RxList<CartItemModel> cartItems = <CartItemModel>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  static const String _guestCartKey = 'guest_cart';
  static const String _pendingSyncKey = 'pending_cart_sync';

  int get cartCount => cartItems.length;

  int get totalQuantity =>
      cartItems.fold(0, (sum, item) => sum + item.quantity.value);

  double get subtotal {
    return cartItems.fold(
      0.0,
          (sum, item) =>
      sum + (double.tryParse(item.price.toString()) ?? 0.0) * item.quantity.value,
    );
  }

  double get shipping => 0.0;

  double get total => subtotal + shipping;

  @override
  void onInit() {
    super.onInit();
    loadGuestCart();

    ever<bool>(auth.isLoggedIn, (loggedIn) async {
      if (loggedIn) {
        await fetchAndMergeCartFromServer();
      }
    });
  }
  String formatCurrency(double usdAmount) {
    final currencyController = Get.find<CurrencyController>();

    final symbol = CurrencyHelper.symbol(
      currencyController.selectedCurrency.value,
    );

    final amount = usdAmount * currencyController.selectedRate.value;

    final formatted = NumberFormat.currency(
      locale: 'en_IN',
      symbol: '',
      decimalDigits: 0,
    ).format(amount);

    return '$symbol $formatted';
  }
  bool isInCart(dynamic id) {
    return cartItems.any((item) => item.id.toString() == id.toString());
  }

  Future<void> addItem(CartItemModel item) async {
    final index =
    cartItems.indexWhere((e) => e.id.toString() == item.id.toString());

    if (index != -1) {

      if (cartItems[index].quantity.value >=
          cartItems[index].availableQuantity) {
        Get.snackbar(
          "Stock Limit",
          "Only ${cartItems[index].availableQuantity} item(s) available in stock.",
          snackPosition: SnackPosition.TOP,
        );
        return;
      }
      cartItems[index].quantity.value++;
    } else {
      cartItems.add(item);
    }
    cartItems.refresh();
    await _saveLocalAndSync();
  }

  Future<void> increaseQty(CartItemModel item) async {
    if (item.quantity.value >= item.availableQuantity) {
      Get.snackbar(
        "Stock Limit",
        "Only ${item.availableQuantity} item(s) available in stock.",
        snackPosition: SnackPosition.TOP,
      );
      return;
    }
    item.quantity.value++;
    cartItems.refresh();
    await _saveLocalAndSync();
  }

  Future<void> decreaseQty(CartItemModel item) async {
    if (item.quantity.value <= 1) return;

    item.quantity.value--;
    cartItems.refresh();
    await _saveLocalAndSync();
  }

  Future<void> removeItem(CartItemModel item) async {
    cartItems.removeWhere((e) => e.id.toString() == item.id.toString());
    cartItems.refresh();
    await _saveLocalAndSync();
  }

  Future<void> clearCart() async {
    cartItems.clear();
    await box.remove(_guestCartKey);

    if (auth.isLoggedIn.value) {
      await syncCartWithServer();
    } else {
      await box.write(_pendingSyncKey, true);
    }
  }

  Future<void> _saveLocalAndSync() async {
    await saveGuestCart();

    if (auth.isLoggedIn.value) {
      await syncCartWithServer();
    } else {
      await box.write(_pendingSyncKey, true);
    }
  }

  Future<void> saveGuestCart() async {
    final data = cartItems.map((item) => item.toJson()).toList();
    await box.write(_guestCartKey, data);
  }

  void loadGuestCart() {
    final data = box.read(_guestCartKey);

    if (data == null || data is! List) return;

    final items = data
        .whereType<Map>()
        .map((e) => CartItemModel.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    cartItems.assignAll(items);
  }
  Future<void> refreshCart() async {
    await auth.checkLogin();

    print("REFRESH LOGIN => ${auth.isLoggedIn.value}");

    if (auth.isLoggedIn.value) {
      await fetchAndMergeCartFromServer();
    } else {
      loadGuestCart();
    }

    cartItems.refresh();
    update();
  }
  Future<void> fetchAndMergeCartFromServer() async {
    print("FETCH CART CALLED");
    print("IS LOGIN => ${auth.isLoggedIn.value}");
    print("AUTH READY => ${auth.authReady.value}");

    if (!auth.isLoggedIn.value) {
      print("USER NOT LOGGED IN");
      return;
    }
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final response = await api.fetchCart();
      print("REFRESH RESPONSE =>");
      print(response);
      final data = response['data'];
      print("DATA => ${response['data']}");
      print("CART => ${response['data']['cart']}");
      List<dynamic> remoteCartList = [];

      if (data is Map<String, dynamic>) {
        final cart = data['cart'];
        if (cart is List) {
          remoteCartList = cart;
        }
      } else if (data is List) {
        remoteCartList = data;
      }

      if (remoteCartList.isEmpty) {
        cartItems.clear();
        cartItems.refresh();

        await saveGuestCart();

        print("CART EMPTY FROM SERVER");
        return;
      }

      print("REMOTE CART LIST =>");
      print(remoteCartList);

      final remoteItems = remoteCartList.map((e) {
        final item = Map<String, dynamic>.from(e as Map);
        final diamond = item['diamond'] is Map
            ? Map<String, dynamic>.from(item['diamond'])
            : <String, dynamic>{};

        return CartItemModel(
          id: diamond['id'] ?? item['id'],
          sku: diamond['sku'] ?? item['sku'],
          diamondTitle: diamond['title'] ?? item['diamondTitle'] ?? '',
          color: diamond['color'] ?? item['color'],
          clarity: diamond['clarity'] ?? item['clarity'],
          cut: diamond['cut'] ?? item['cut'],
          subtitle:
          "${diamond['color'] ?? ''} Color • "
              "${diamond['clarity'] ?? ''} Clarity • "
              "${diamond['cut'] ?? ''} Cut",
          price: diamond['price'] ?? item['price'] ?? 0,
          image: diamond['image'] ?? item['image'] ?? '',
          diamondData: diamond.isNotEmpty ? diamond : null,
          availableQuantity: diamond['quantity'] ?? 0,
          initialQty: item['quantity'] ?? 1,
        );
      }).toList();
      print("REMOTE ITEMS CREATED => ${remoteItems.length}");
      cartItems.assignAll(remoteItems);
      cartItems.refresh();
      await saveGuestCart();
      print("REMOTE ITEMS => ${remoteItems.length}");
      print("CURRENT CART => ${cartItems.length}");
    } catch (e) {
      errorMessage.value = e.toString();
      print("FETCH CART ERROR => $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> syncCartWithServer() async {
    if (!auth.isLoggedIn.value) return;

    try {
      final payload = cartItems.map((item) {
        final diamond = item.diamondData ??
            {
              "id": item.id,
              "sku": item.sku,
              "title": item.diamondTitle,
              "slug": null,
              "seoTitle": null,
              "seoDescription": null,
              "seoKeywords": null,
              "shape": null,
              "price": item.price,
              "originalPrice": null,
              "discountPercent": null,
              "carat": null,
              "color": null,
              "clarity": null,
              "cut": null,
              "image": item.image,
              "images": item.image.toString().isNotEmpty ? [item.image] : [],
              "certification": null,
              "certNumber": null,
              "certificateFile": null,
              "isLabGrown": false,
              "measurements": null,
              "depthPercent": null,
              "tablePercent": null,
              "polish": null,
              "symmetry": null,
              "fluorescence": null,
              "quantity": item.quantity.value,
              "averageRating": null,
              "ratingCount": null,
              "reviewCount": null,
              "buyCount": null,
              "createdAt": null,
              "updatedAt": null,
              "localizedContent": null,
            };

        return {
          "diamond": diamond,
          "quantity": item.quantity.value,
        };
      }).toList();


      print("CART REQUEST =>");
      print({"cart": payload});

      final response = await api.updateCart(payload);

      print("CART SYNC SUCCESS");
      print(response);
      await box.write(_pendingSyncKey, false);
      await fetchAndMergeCartFromServer();
      cartItems.refresh();
      update();
    } catch (e) {
      print("CART SYNC ERROR => $e");
      await box.write(_pendingSyncKey, true);
    }
  }}