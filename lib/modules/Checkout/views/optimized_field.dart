import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kdt/utils/app_decorations.dart';
import '../../../utils/app_colors.dart';
import '../../../utils/app_text_style.dart';

class OptimizedField extends StatefulWidget {
  final String title;
  final String? hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputAction textInputAction;
  final TextInputType keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final String? errorText;

  const OptimizedField({
    super.key,
    required this.title,
    required this.controller,
    this.hint,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.inputFormatters,
    this.errorText,
  });

  @override
  State<OptimizedField> createState() => _OptimizedFieldState();
}

class _OptimizedFieldState extends State<OptimizedField> {
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    _focusNode.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  Color get _borderColor {
    if (widget.errorText != null) return AppColors.error;
    if (_focusNode.hasFocus) return AppColors.primaryDark;
    return AppColors.borderGray;
  }

  Color get _titleColor {
    return AppColors.textPrimary;
  }

  Color get _cursorColor {
    if (widget.errorText != null) return AppColors.error;
    return AppColors.primaryDark;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: AppTextStyles.poppins(
              fontSize: AppFontSizes.s13,
              fontWeight: FontWeight.w500,
              color: _titleColor,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            maxLength: widget.maxLength,
            inputFormatters: widget.inputFormatters,
            cursorColor: AppColors.primaryDark,
            style: AppTextStyles.poppins(
              fontSize: AppFontSizes.s14,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
            validator: widget.validator,
            decoration: _buildInputDecoration().copyWith(
              errorText: widget.errorText,
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      hintText: widget.hint,
      hintStyle: AppTextStyles.poppins(
        fontSize: AppFontSizes.s12,
        fontWeight: FontWeight.w400,
        color: AppColors.darkGray,
      ),
      filled: true,
      fillColor: AppColors.white,
      isDense: true,
      counterText: "",
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),

      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDecorations.inputRadius),
        borderSide: const BorderSide(
          color: AppColors.borderGray,
          width: 1,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDecorations.inputRadius),
        borderSide: const BorderSide(
          color: AppColors.borderGray,
          width: 1,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDecorations.inputRadius),
        borderSide: BorderSide(
          color: widget.errorText != null
              ? AppColors.error
              : AppColors.primaryDark,
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDecorations.inputRadius),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDecorations.inputRadius),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),

      errorStyle: AppTextStyles.poppins(
        fontSize: AppFontSizes.s12,
        fontWeight: FontWeight.w400,
        color: AppColors.error,
      ),
    );
  }
}