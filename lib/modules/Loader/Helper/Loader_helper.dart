import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Loader Service/Loader_service.dart';

class AppNavigator {
  static Future<void> to(
    String route, {
    dynamic arguments,
  }) async {
    LoaderService.show();
    await Future.delayed(const Duration(milliseconds: 500));
    LoaderService.hide();
    
    if (route == "/navigation") {
      Get.offAllNamed(route, arguments: arguments);
    } else {
      Get.toNamed(route, arguments: arguments);
    }
  }

  static Future<void> offAll(
    String route, {
    dynamic arguments,
  }) async {
    LoaderService.show();
    await Future.delayed(const Duration(milliseconds: 500));
    LoaderService.hide();
    Get.offAllNamed(route, arguments: arguments);
  }

  static Future<void> toWidget(Widget page) async {
    LoaderService.show();
    await Future.delayed(const Duration(milliseconds: 500));
    LoaderService.hide();
    Get.to(page);
  }
}
