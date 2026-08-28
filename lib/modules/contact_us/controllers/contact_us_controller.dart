import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../Contact_api_service.dart';

class ContactController extends GetxController {
  final ContactApiService api = Get.find<ContactApiService>();

  final formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final subjectController = TextEditingController();
  final messageController = TextEditingController();
  final autoValidate = AutovalidateMode.disabled.obs;

  final isLoading = false.obs;

  Future<void> submitContact() async {
    autoValidate.value = AutovalidateMode.onUserInteraction;

    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isLoading.value = true;

      final response = await api.submitContact(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        phone: phoneController.text.trim(),
        subject: subjectController.text.trim(),
        message: messageController.text.trim(),
      );

      Get.snackbar(
        "Message Sent",
        "Your message has been sent successfully. We will get back to you soon.",
        snackPosition: SnackPosition.TOP,
      );

      clearForm();

      autoValidate.value = AutovalidateMode.disabled;
    } catch (e) {
      Get.snackbar(
        "Submission Failed",
        "We couldn't send your message. Please check your connection and try again.",
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isLoading.value = false;
    }
  }
  void clearForm() {
    nameController.clear();
    emailController.clear();
    phoneController.clear();
    subjectController.clear();
    messageController.clear();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    subjectController.dispose();
    messageController.dispose();
    super.onClose();
  }
}