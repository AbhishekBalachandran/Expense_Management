import 'package:expense_manager/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.isEnabled,
    required this.onTap,
    required this.text,
  });

  final String text;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: AppDimensions.buttonHeight,
        width: double.infinity,
        decoration: BoxDecoration(
          color: isEnabled
              ? AppColors.primary
              : AppColors.primary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: AppTextStyles.button.copyWith(
            color: isEnabled ? AppColors.primaryText : AppColors.textDisabled,
          ),
        ),
      ),
    );
  }
}
