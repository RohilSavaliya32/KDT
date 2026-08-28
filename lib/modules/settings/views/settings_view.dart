import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Text(controller.errorMessage.value),
          );
        }

        final home = controller.settings.value?.home;
        final bank = controller.settings.value?.bank;
        final contact = controller.settings.value?.contact;
        final firebase = controller.settings.value?.firebase;

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              home?.heroTitle ?? '',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(home?.heroSubtitle ?? ''),
            const SizedBox(height: 20),
            Text('GST No: ${home?.gstNo ?? ''}'),
            Text('Reg No: ${home?.regNo ?? ''}'),
            Text('Phone 1: ${home?.phone1 ?? ''}'),
            Text('Phone 2: ${home?.phone2 ?? ''}'),
            Text('Email: ${home?.footerEmail ?? ''}'),
            const SizedBox(height: 20),
            Text(
              'Bank',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('Bank Name: ${bank?.bankName ?? ''}'),
            Text('Account Name: ${bank?.accountName ?? ''}'),
            Text('Account Number: ${bank?.accountNumber ?? ''}'),
            Text('SWIFT Code: ${bank?.swiftCode ?? ''}'),
            const SizedBox(height: 20),
            Text(
              'Contact',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('WhatsApp: ${contact?.whatsappNumber ?? ''}'),
            Text('India Phone: ${contact?.phoneIndia ?? ''}'),
            Text('Korea Phone: ${contact?.phoneKorea ?? ''}'),
            const SizedBox(height: 20),
            Text(
              'Firebase',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text('App ID: ${firebase?.appId ?? ''}'),
            Text('Project ID: ${firebase?.projectId ?? ''}'),
          ],
        );
      }),
    );
  }
}