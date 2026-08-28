import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Loader/Loader.dart';

class LoaderService {
  static bool _isShowing = false;

  static void show() {
    if (_isShowing) return;

    _isShowing = true;

    Get.dialog(
      const AppLoader(),
      barrierDismissible: false,
      barrierColor: Colors.transparent,
    );
  }

  static void hide() {
    if (!_isShowing) return;

    _isShowing = false;

    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }
}