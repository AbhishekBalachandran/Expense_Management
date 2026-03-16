import 'package:expense_manager/shared/widgets/loading_overlay_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../bloc/auth/auth_bloc.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_theme.dart';

class MobileLoginScreen extends StatefulWidget {
  const MobileLoginScreen({super.key});

  @override
  State<MobileLoginScreen> createState() => _MobileLoginScreenState();
}

class _MobileLoginScreenState extends State<MobileLoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(validate);
  }

  void validate() {
    final digits = _phoneController.text.trim();
    setState(() => _isValid = digits.length == 10);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void submit() {
    try {
      final phone = '+91${_phoneController.text.trim()}';
      context.read<AuthBloc>().add(SendOtpEvent(phone: phone));
    } catch (e) {
      debugPrint('Error in submit: $e');
      showError('An error occurred. Please try again.');
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is OtpSentState) {
          context.push(AppRoutes.otp, extra: {'mobile': state.phone});
        } else if (state is AuthenticatedState) {
          context.go(AppRoutes.home);
        } else if (state is AuthErrorState) {
          showError(state.message);
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return LoadingOverlay(
          isLoading: isLoading,
          child: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    const SizedBox(height: 48),
                    const Text(
                      'Get Started',
                      style: AppTextStyles.headingLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Log In Using Phone & OTP',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 36),

                    // input field
                    PhoneInputField(
                      controller: _phoneController,
                      focusNode: _focusNode,
                    ),

                    const SizedBox(height: 20),

                    //  submit
                    GestureDetector(
                      onTap: _isValid ? submit : null,
                      child: Container(
                        height: AppDimensions.buttonHeight,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _isValid
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'Continue',
                          style: AppTextStyles.button.copyWith(
                            color: _isValid
                                ? AppColors.primaryText
                                : AppColors.textDisabled,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class PhoneInputField extends StatelessWidget {
  const PhoneInputField({
    super.key,
    required this.controller,
    required this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.inputFieldHeight,
      decoration: BoxDecoration(
        color: AppColors.textfieldSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.borderColor, width: 0.8),
      ),
      child: Row(
        children: [
          // prefix section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              border: Border(
                right: BorderSide(color: AppColors.primaryText, width: 0.8),
              ),
            ),
            child: Text(
              '+91',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primaryText,
              ),
            ),
          ),

          // phone number input field
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.phone,
              maxLength: 10,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Phone',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                counterText: '',
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ),
        ],
      ),
    );
  }
}
