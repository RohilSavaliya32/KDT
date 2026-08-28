import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kdt/modules/translations/Translation_key/translation_keys.dart';
import 'daimond_card/controllers/daimond_card_controller.dart';

class NoDataFoundWidget extends StatelessWidget {
  const NoDataFoundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Prevent system text scaling from affecting UI
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaleFactor: 1.0,
        boldText: false,
      ),
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(42, 80, 42, 0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const SizedBox(height: 100),
            _buildEmptyIcon(),
            const SizedBox(height: 24),
            _buildTitleText(),
            const SizedBox(height: 12),
            _buildSubtitleText(),
            const SizedBox(height: 24),
            _buildTryAgainButton(),
            const SizedBox(height: 100),
          ],
        ),
      );
  }

  Widget _buildEmptyIcon() {
    return Icon(
      Icons.inventory_2_outlined,
      size: 75,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildTitleText() {
    return Text(
      TranslationKeys.noDiamondsFound.tr,
      style: GoogleFonts.lora(
        fontSize: 22, // Fixed size to prevent scaling
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
      textAlign: TextAlign.center,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildSubtitleText() {
    return Text(
      TranslationKeys.noDiamondsMatchingCriteria.tr,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        height: 1.5,
        color: Colors.grey.shade600,
      ),
    );
  }

  Widget _buildTryAgainButton() {
    return OutlinedButton.icon(
      onPressed: _refreshDiamonds,
      icon: const Icon(Icons.refresh),
      label: Text(TranslationKeys.tryAgain.tr),
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF005B45),
        side: const BorderSide(
          color: Color(0xFF005B45),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _refreshDiamonds() async {
    try {
      final controller = Get.find<DiamondCardController>();
      await controller.refreshDiamonds();
    } catch (e) {
      // Handle error if controller is not found
      debugPrint('Error refreshing diamonds: $e');
    }
  }
}