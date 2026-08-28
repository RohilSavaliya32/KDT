import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/utils/app_colors.dart';
import 'package:kdt/utils/app_text_style.dart';
import '../translations/Translation_key/translation_keys.dart';

class CancelOrderDialog extends StatefulWidget {
  final Future<bool> Function(String reason) onConfirm;

  const CancelOrderDialog({
    super.key,
    required this.onConfirm,
  });

  @override
  State<CancelOrderDialog> createState() =>
      _CancelOrderDialogState();
}

class _CancelOrderDialogState
    extends State<CancelOrderDialog> {
  final TextEditingController _reasonController =
  TextEditingController();

  bool _loading = false;

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _loading = true);

    final ok = await widget.onConfirm(
      _reasonController.text.trim(),
    );

    if (!mounted) return;

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.background,
      surfaceTintColor: AppColors.background,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      insetPadding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 24,
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            // ====================================================
            // HEADER
            // ====================================================

            Row(
              children: [
                Expanded(
                  child: Text(
                    TranslationKeys.cancelOrder.tr,
                    style: AppTextStyles.lora(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.foreground,
                    ),
                  ),
                ),

                IconButton(
                  onPressed: _loading
                      ? null
                      : () => Get.back(),
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.foreground,
                  ),
                  padding: EdgeInsets.zero,
                  constraints:
                  const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // ====================================================
            // DESCRIPTION
            // ====================================================

            Text(
              TranslationKeys
                  .cancelOrderConfirmation.tr,
              style: AppTextStyles.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 18),

            // ====================================================
            // REASON LABEL
            // ====================================================

            Text(
              TranslationKeys
                  .reasonForCancellation.tr,
              style: AppTextStyles.poppins(
                fontSize: 14,
                color: AppColors.foreground,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            // ====================================================
            // REASON TEXT FIELD
            // ====================================================

            TextField(
              controller: _reasonController,
              maxLines: 4,
              enabled: !_loading,
              style: AppTextStyles.poppins(
                fontSize: 15,
                color: AppColors.foreground,
              ),
              cursorColor: AppColors.accent,
              decoration: InputDecoration(
                hintText: TranslationKeys
                    .tellUsWhyCancelling.tr,
                hintStyle: AppTextStyles.poppins(
                  fontSize: 14,
                  color:
                  AppColors.mutedForeground,
                ),
                filled: true,
                fillColor:
                AppColors.background,
                contentPadding:
                const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(8),
                  borderSide:
                  const BorderSide(
                    color: AppColors.border,
                  ),
                ),
                enabledBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(8),
                  borderSide:
                  const BorderSide(
                    color: AppColors.border,
                  ),
                ),
                focusedBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(8),
                  borderSide:
                  const BorderSide(
                    color: AppColors.accent,
                    width: 1.5,
                  ),
                ),
                disabledBorder:
                OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(8),
                  borderSide:
                  const BorderSide(
                    color: AppColors.borderGray,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 18),

            // ====================================================
            // ACTION BUTTONS
            // ====================================================

            Row(
              mainAxisAlignment:
              MainAxisAlignment.end,
              children: [
                // BACK
                SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: _loading
                        ? null
                        : () => Get.back(),
                    style:
                    OutlinedButton.styleFrom(
                      foregroundColor:
                      AppColors.foreground,
                      disabledForegroundColor:
                      AppColors.disabledGray,
                      side: const BorderSide(
                        color: AppColors.border,
                      ),
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      TranslationKeys.back.tr,
                      style:
                      AppTextStyles.poppins(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // CONFIRM CANCELLATION
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed:
                    _loading ? null : _submit,
                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      AppColors.error,
                      foregroundColor:
                      AppColors.white,
                      disabledBackgroundColor:
                      AppColors.accentDisabled,
                      disabledForegroundColor:
                      AppColors.white,
                      elevation: 0,
                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(8),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                        color:
                        AppColors.white,
                      ),
                    )
                        : Text(
                      TranslationKeys
                          .confirmCancellation
                          .tr,
                      style:
                      AppTextStyles.poppins(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w600,
                        color:
                        AppColors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}