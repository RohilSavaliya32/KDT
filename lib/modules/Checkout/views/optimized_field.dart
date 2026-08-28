import 'package:flutter/material.dart';
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

  const OptimizedField({
    super.key,
    required this.title,
    required this.controller,
    this.hint,
    this.validator,
    this.textInputAction = TextInputAction.next,
    this.keyboardType = TextInputType.text,
    this.maxLength,
  });

  @override
  State<OptimizedField> createState() => _OptimizedFieldState();
}

class _OptimizedFieldState extends State<OptimizedField> {
  final FocusNode _focusNode = FocusNode();

  bool _hasError = false;

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
    if (_hasError) return AppColors.error;
    if (_focusNode.hasFocus) return AppColors.primaryDark;
    return AppColors.borderGray;
  }

  Color get _titleColor {
    return AppColors.textPrimary;
  }

  Color get _cursorColor {
    if (_hasError) return AppColors.error;
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
            cursorColor: _cursorColor,
            style: AppTextStyles.poppins(
              fontSize: AppFontSizes.s14,
              fontWeight: FontWeight.w400,
              color: AppColors.textPrimary,
            ),
            validator: (value) {
              final result = widget.validator?.call(value);

              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (!mounted) return;

                final hasError = result != null;

                if (_hasError != hasError) {
                  setState(() {
                    _hasError = hasError;
                  });
                }
              });

              return result;
            },
            decoration: _buildInputDecoration(),
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
        borderRadius: BorderRadius.circular(2),
        borderSide: BorderSide(
          color: _borderColor,
          width: 1,
        ),
      ),

      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: BorderSide(
          color: _borderColor,
          width: 1,
        ),
      ),

      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: BorderSide(
          color: _hasError
              ? AppColors.error
              : AppColors.primaryDark,
          width: 1.5,
        ),
      ),

      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: 1.5,
        ),
      ),

      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(2),
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