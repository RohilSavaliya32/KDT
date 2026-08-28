import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kdt/utils/app_colors.dart';
import 'package:kdt/utils/app_text_style.dart';
import 'package:kdt/routes/app_routes.dart';

import '../../../data/Setting_Cont.dart';
import '../Loader/Helper/Loader_helper.dart';
import '../translations/Translation_key/translation_keys.dart';

class OrderPaymentRequiredCard extends StatefulWidget {
  final String orderId;
  final String formattedAmount;
  final double amountValue;
  final String currency;

  const OrderPaymentRequiredCard({
    super.key,
    required this.orderId,
    required this.formattedAmount,
    required this.amountValue,
    required this.currency,
  });

  @override
  State<OrderPaymentRequiredCard> createState() =>
      _OrderPaymentRequiredCardState();
}

class _OrderPaymentRequiredCardState
    extends State<OrderPaymentRequiredCard> {
  bool _showDetails = false;

  SettingsDataController get _settingsController =>
      Get.find<SettingsDataController>();

  String _safeValue(String value) =>
      value.trim().isNotEmpty ? value.trim() : 'N/A';

  @override
  Widget build(BuildContext context) {
    final bankName = _safeValue(
      _settingsController.getBankName(),
    );

    final accountName = _safeValue(
      _settingsController.getAccountName(),
    );

    final accountNumber = _safeValue(
      _settingsController.getAccountNumber(),
    );

    final routingNumber = _safeValue(
      _settingsController.getRoutingNumber(),
    );

    final swiftCode = _safeValue(
      _settingsController.getSwiftCode(),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // Payment required = light warning background
        color: AppColors.lightGray,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          // =====================================================
          // PAYMENT REQUIRED TITLE
          // =====================================================

          Text(
            TranslationKeys.paymentRequired.tr,
            style: AppTextStyles.poppins(
              fontSize: 22,
              fontWeight: FontWeight.w400,
              color: AppColors.warning,
            ),
          ),

          const SizedBox(height: 10),

          // =====================================================
          // DESCRIPTION
          // =====================================================

          Text(
            TranslationKeys
                .paymentRequiredDescription.tr,
            style: AppTextStyles.poppins(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 12),

          // =====================================================
          // VIEW BANK DETAILS
          // =====================================================

          InkWell(
            onTap: () {
              setState(() {
                _showDetails = !_showDetails;
              });
            },
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: double.infinity,
              padding:
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius:
                BorderRadius.circular(4),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      TranslationKeys
                          .viewBankDetails.tr,
                      style:
                      AppTextStyles.poppins(
                        fontSize: 14,
                        fontWeight:
                        FontWeight.w500,
                        color:
                        AppColors.foreground,
                      ),
                    ),
                  ),

                  Icon(
                    _showDetails
                        ? Icons.expand_less
                        : Icons.expand_more,
                    color:
                    AppColors.iconGray,
                  ),
                ],
              ),
            ),
          ),

          // =====================================================
          // BANK DETAILS
          // =====================================================

          if (_showDetails) ...[
            const SizedBox(height: 10),

            Container(
              width: double.infinity,
              padding:
              const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius:
                BorderRadius.circular(4),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    '${TranslationKeys.bank.tr}: $bankName',
                    style:
                    AppTextStyles.poppins(
                      fontSize: 13,
                      color:
                      AppColors.foreground,
                    ),
                  ),

                  Text(
                    '${TranslationKeys.accountName.tr}: $accountName',
                    style:
                    AppTextStyles.poppins(
                      fontSize: 13,
                      color:
                      AppColors.foreground,
                    ),
                  ),

                  Text(
                    '${TranslationKeys.accountNumber.tr}: $accountNumber',
                    style:
                    AppTextStyles.poppins(
                      fontSize: 13,
                      color:
                      AppColors.foreground,
                    ),
                  ),

                  if (routingNumber != 'N/A')
                    Text(
                      '${TranslationKeys.routingNumber.tr}: $routingNumber',
                      style:
                      AppTextStyles.poppins(
                        fontSize: 13,
                        color:
                        AppColors.foreground,
                      ),
                    ),

                  if (swiftCode != 'N/A')
                    Text(
                      '${TranslationKeys.swiftCode.tr}: $swiftCode',
                      style:
                      AppTextStyles.poppins(
                        fontSize: 13,
                        color:
                        AppColors.foreground,
                      ),
                    ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // =====================================================
          // UPLOAD RECEIPT BUTTON
          // =====================================================

          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton.icon(
              onPressed: () {
                AppNavigator.to(
                  AppRoutes.Payment_Summary,
                  arguments: {
                    'orderId': widget.orderId,
                    'amount': widget.amountValue,
                    'currency': widget.currency,
                  },
                );
              },
              icon: const Icon(
                Icons.upload_file,
                size: 18,
                color: AppColors.white,
              ),
              label: Text(
                TranslationKeys
                    .uploadReceipt.tr,
                style: AppTextStyles.poppins(
                  fontSize: 14,
                  fontWeight:
                  FontWeight.w500,
                  color: AppColors.white,
                ),
              ),
              style:
              ElevatedButton.styleFrom(
                backgroundColor:
                AppColors.accent,
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
                  BorderRadius.circular(2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
