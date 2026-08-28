import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/utils/app_text_style.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data/Setting_Cont.dart';
import '../modules/Diamonds_Details/controllers/DiamondDetailView_controller.dart';


class AppointmentDialog extends StatelessWidget {
  AppointmentDialog({super.key});


  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;


    final settingsController = Get.find<SettingsDataController>();

    final settings = settingsController.contact;

    final hasKoreaLink =
        settings?.calendlyKorea?.isNotEmpty ?? false;

    final hasIndiaLink =
        settings?.calendlyIndia?.isNotEmpty ?? false;

    return Dialog(
      backgroundColor: Colors.white,
      elevation: 0,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isMobile ? 20 : 40,
        vertical: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const Spacer(),
                  Expanded(
                    flex: 8,
                    child: Text(
                      "Book Appointment",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.lora(
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1F1F1F),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: Get.back,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),

              const SizedBox(height: 8),

               Text(
                "Choose your preferred location for a private viewing.",
                textAlign: TextAlign.center,
                style: AppTextStyles.poppins(
                  fontSize: 15,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 24),

              // Korea option - only show if calendlyKorea is available
              if (hasKoreaLink)
                _locationCard(
                  flag: "🇰🇷",
                  title: "Korea",
                  location: "Seoul, Jongno-gu",
                    onTap: () async {
                      Get.back();

                      final settings = Get.find<SettingsDataController>().contact;

                      if (settings?.calendlyKorea?.isNotEmpty ?? false) {
                        await launchUrl(
                          Uri.parse(settings!.calendlyKorea!),
                          mode: LaunchMode.platformDefault,
                        );
                      } else {
                        Get.snackbar(
                          "Not Available",
                          "Korea appointment link is not available",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                ),

              if (hasKoreaLink && hasIndiaLink)
                const SizedBox(height: 14),
              // India option - only show if calendlyIndia is available
              if (hasIndiaLink)
                _locationCard(
                  flag: "🇮🇳",
                  title: "India",
                  location: "Surat, Gujarat",
                    onTap: () async {
                      Get.back();

                      final settings = Get.find<SettingsDataController>().contact;

                      if (settings?.calendlyIndia?.isNotEmpty ?? false) {
                        await launchUrl(
                          Uri.parse(settings!.calendlyIndia!),
                          mode: LaunchMode.platformDefault,
                        );
                      } else {
                        Get.snackbar(
                          "Not Available",
                          "India appointment link is not available",
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    },
                ),

              // Show message if no appointments are available
              if (!hasKoreaLink && !hasIndiaLink)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.event_busy_outlined,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "No appointments available at the moment",
                        textAlign: TextAlign.center,
                        style: AppTextStyles.poppins(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),

                    ],
                  ),
                ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  Widget _locationCard({
    required String flag,
    required String title,
    required String location,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFE8E8E8),
          ),
        ),
        child: Row(
          children: [
            Text(
              flag,
              style:  AppTextStyles.poppins(fontSize: 30),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.lora(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1F1F1F),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: AppTextStyles.poppins(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.open_in_new_rounded,
              size: 18,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}