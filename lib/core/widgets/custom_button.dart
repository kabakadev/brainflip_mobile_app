import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

enum ButtonType { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double? height;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height ?? 50,
      child: _buildButton(isDisabled),
    );
  }

  Widget _buildButton(bool isDisabled) {
    switch (type) {
      case ButtonType.primary:
        return _buildPrimaryButton(isDisabled);
      case ButtonType.secondary:
        return _buildSecondaryButton(isDisabled);
      case ButtonType.outline:
        return _buildOutlineButton(isDisabled);
      case ButtonType.text:
        return _buildTextButton(isDisabled);
    }
  }

  Widget _buildPrimaryButton(bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.gray300,
        disabledForegroundColor: AppColors.gray500,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        // ===== FIX 1: Add textStyle property =====
        textStyle: AppTextStyles.button,
      ),
      // ===== FIX 2: Pass the correct spinner/content color =====
      child: _buildButtonContent(AppColors.white),
    );
  }

  Widget _buildSecondaryButton(bool isDisabled) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.gray300,
        disabledForegroundColor: AppColors.gray500,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        // ===== FIX 1: Add textStyle property =====
        textStyle: AppTextStyles.button,
      ),
      // ===== FIX 2: Pass the correct spinner/content color =====
      child: _buildButtonContent(AppColors.white),
    );
  }

  Widget _buildOutlineButton(bool isDisabled) {
    return OutlinedButton(
      onPressed: isDisabled ? null : onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.gray500,
        side: BorderSide(
          color: isDisabled ? AppColors.gray300 : AppColors.primary,
          width: 1.5,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        // ===== FIX 1: Add textStyle property =====
        textStyle: AppTextStyles.button,
      ),
      // ===== FIX 2: Pass the correct spinner/content color =====
      child: _buildButtonContent(AppColors.primary),
    );
  }

  Widget _buildTextButton(bool isDisabled) {
    return TextButton(
      onPressed: isDisabled ? null : onPressed,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.primary,
        disabledForegroundColor: AppColors.gray500,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        // ===== FIX 1: Add textStyle property =====
        textStyle: AppTextStyles.button,
      ),
      // ===== FIX 2: Pass the correct spinner/content color =====
      child: _buildButtonContent(AppColors.primary),
    );
  }

  // ===== FIX 2: Update signature to accept a color =====
  Widget _buildButtonContent(Color contentColor) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          // ===== FIX 2: Use the dynamic contentColor =====
          valueColor: AlwaysStoppedAnimation<Color>(contentColor),
        ),
      );
    }

    if (icon != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20), // Icon inherits color from styleFrom
          const SizedBox(width: 8),
          // ===== FIX 1: Remove hardcoded text style =====
          Text(text), // Text inherits color and style from styleFrom
        ],
      );
    }

    // ===== FIX 1: Remove hardcoded text style =====
    return Text(text); // Text inherits color and style from styleFrom
  }
}
