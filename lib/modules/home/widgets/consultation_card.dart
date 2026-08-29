import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kdt/utils/app_colors.dart';
import '../../../routes/app_routes.dart';
import '../../../utils/AppointmentDialog.dart';
import '../../Loader/Helper/Loader_helper.dart';
import '../../translations/Translation_controllers/language_controller.dart';
import '../../translations/Translation_key/translation_keys.dart';

class ConsultationCard extends StatelessWidget {
  const ConsultationCard({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final _ViewModel vm = _ViewModel(constraints.maxWidth);

        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: Container(
            width: double.infinity,
            color: const Color(0xFFF8F8F8),
            padding: EdgeInsets.symmetric(
              horizontal: vm.horizontalPadding,
              vertical: vm.verticalPadding,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: GetBuilder<LanguageController>(
                  builder: (langController) {
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLabel(vm),
                        SizedBox(height: vm.mediumSpacing),
                        _buildTitle(vm),
                        SizedBox(height: vm.mediumSpacing),
                        _buildDescription(vm),
                        SizedBox(height: vm.largeSpacing),
                        _buildButtons(context, vm),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(_ViewModel vm) {
    return Text(
      TranslationKeys.expertGuidance.tr,
      textAlign: TextAlign.center,
      style: TextStyle(
        color: const Color(0xFF005234),
        letterSpacing: 5,
        fontSize: vm.labelSize,
        fontWeight: FontWeight.w500,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildTitle(_ViewModel vm) {
    return Text(
      TranslationKeys.needHelpFindingDiamond.tr,
      textAlign: TextAlign.center,
      style: GoogleFonts.lora(
        fontSize: vm.titleSize,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: const Color(0xFF1A1A1A),
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDescription(_ViewModel vm) {
    return Text(
      TranslationKeys.consultationDescription.tr,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: vm.descriptionSize,
        color: AppColors.mutedForeground,
        height: 1.6,
      ),
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildButtons(BuildContext context, _ViewModel vm) {
    return Column(
      children: [
        // =========================================================
        // Schedule Consultation Button
        // =========================================================
        SizedBox(
          width: vm.buttonWidth,
          height: vm.buttonHeight,
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AppointmentDialog(),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              TranslationKeys.scheduleConsultation.tr,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                letterSpacing: .8,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),

        const SizedBox(height: 12),

        // =========================================================
        // Contact Us Button
        // =========================================================
        SizedBox(
          width: vm.buttonWidth,
          height: vm.buttonHeight,
          child: OutlinedButton(
            onPressed: () {
              AppNavigator.to("/contact-us");
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.black,
              side: const BorderSide(
                color: Color(0xFF9E9E9E),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              TranslationKeys.contactUs.tr,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }
}

class _ViewModel {
  final double width;

  const _ViewModel(this.width);

  // Breakpoints
  bool get isMobile => width < 600;
  bool get isTablet => width >= 600 && width < 1024;
  bool get isDesktop => width >= 1024;
  bool get isVerySmall => width < 380;

  // Padding
  double get horizontalPadding {
    return 0;
  }

  double get verticalPadding {
    if (isVerySmall) return 30;
    if (isMobile) return 40;
    if (isTablet) return 50;
    return 60;
  }

  // Text Sizes
  double get labelSize {
    if (isVerySmall) return 10;
    if (isMobile) return 12;
    if (isTablet) return 13;
    return 14;
  }

  double get titleSize {
    if (isVerySmall) return 24;
    if (isMobile) return 34;
    if (isTablet) return 42;
    return 48;
  }

  double get descriptionSize {
    if (isVerySmall) return 13;
    if (isMobile) return 15;
    if (isTablet) return 17;
    return 18;
  }

  // Spacing
  double get mediumSpacing {
    if (isVerySmall) return 14;
    if (isMobile) return 18;
    if (isTablet) return 22;
    return 24;
  }

  double get largeSpacing {
    if (isVerySmall) return 22;
    if (isMobile) return 28;
    if (isTablet) return 32;
    return 36;
  }

  // Button
  double get buttonWidth {
    if (isMobile) return double.infinity;
    if (isTablet) return 280;
    return 320;
  }

  double get buttonHeight {
    if (isVerySmall) return 48;
    return 54;
  }
}