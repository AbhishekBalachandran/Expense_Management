import 'package:expense_manager/bloc/auth/auth_bloc.dart';
import 'package:expense_manager/core/router/app_routes.dart';
import 'package:expense_manager/core/theme/app_theme.dart';
import 'package:expense_manager/shared/widgets/custom_button.dart';
import 'package:expense_manager/shared/widgets/loading_overlay_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class OtpScreen extends StatefulWidget {
  final String phone;
  const OtpScreen({super.key, required this.phone});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  String get _otp => _controllers.map((c) => c.text).join();
  bool get _isComplete => _otp.length == 6;
  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  void onChanged(int index, String value) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
    setState(() {});
  }

  void submit() {
    if (!_isComplete) return;
    context.read<AuthBloc>().add(VerifyOtpEvent(otp: _otp));
  }

  void resend() {
    for (final c in _controllers) {
      c.text = '';
      c.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {});
    context.read<AuthBloc>().add(ResendOtpEvent());
  }

  String hidePhoneNumberFormat(String phone) {
    if (phone.length < 6) return phone;
    final digits = phone.replaceAll('+91', '');
    return '${digits.substring(0, 4)}****${digits.substring(digits.length - 2)}';
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
        if (state is NewUserState) {
          context.push(AppRoutes.nickname, extra: {'phone': state.phone});
        } else if (state is AuthenticatedState) {
          context.go(AppRoutes.home);
        } else if (state is AuthErrorState) {
          showError(state.message);
          // clearing otp values
          for (final c in _controllers) {
            c.clear();
          }
          _focusNodes[0].requestFocus();
          setState(() {});
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        double secondsRemaining = 0;
        bool canResend = true;

        if (state is OtpSentState) {
          secondsRemaining = state.secondsRemaining;
          canResend = false;
        } else if (state is OtpTimerState) {
          secondsRemaining = state.secondsRemaining;
          canResend = secondsRemaining <= 0.0;
        }
        return LoadingOverlay(
          isLoading: isLoading,
          child: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                child: Column(
                  crossAxisAlignment: .start,
                  children: [
                    // back button
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.borderColor,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusMd,
                          ),
                          color: Colors.transparent,
                        ),
                        child: const Icon(
                          Icons.chevron_left_rounded,
                          color: AppColors.primaryText,
                          size: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    const Text('Verify OTP', style: AppTextStyles.headingLarge),
                    const SizedBox(height: 8),
                    Text(
                      'Enter the 6-Digit code sent to ${hidePhoneNumberFormat(widget.phone)}\n',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    GestureDetector(
                      onTap: () => context.pop(),
                      child: Text(
                        'Change Number',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.blue,
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    OtpBoxRow(
                      controllers: _controllers,
                      focusNodes: _focusNodes,
                      onChanged: onChanged,
                    ),

                    const SizedBox(height: 28),

                    CustomButton(
                      isEnabled: _isComplete,
                      onTap: submit,
                      text: "Verify",
                    ),

                    const SizedBox(height: 20),

                    ResendOTP(
                      secondsRemaining: secondsRemaining,
                      canResend: canResend,
                      onResend: resend,
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

class ResendOTP extends StatelessWidget {
  const ResendOTP({
    super.key,
    required this.secondsRemaining,
    required this.canResend,
    required this.onResend,
  });

  final double secondsRemaining;
  final bool canResend;
  final VoidCallback onResend;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (!canResend) ...[
          Text('Resend OTP', style: AppTextStyles.bodySmall),
          const SizedBox(width: 4),

          Text('in  ${secondsRemaining}s', style: AppTextStyles.bodySmall),
        ] else
          GestureDetector(
            onTap: onResend,
            child: Text(
              'Resend',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}

class OtpBoxRow extends StatelessWidget {
  const OtpBoxRow({
    super.key,
    required this.controllers,
    required this.focusNodes,
    required this.onChanged,
  });

  final List<TextEditingController> controllers;
  final List<FocusNode> focusNodes;
  final void Function(int index, String value) onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(controllers.length, (index) {
        return OtpBox(
          controller: controllers[index],
          focusNode: focusNodes[index],
          onChanged: (v) => onChanged(index, v),
        );
      }),
    );
  }
}

class OtpBox extends StatelessWidget {
  const OtpBox({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 51,
      height: 64,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 1,
        style: AppTextStyles.headingMedium,
        onChanged: onChanged,
        decoration: InputDecoration(
          counterText: '',
          hintText: '-',
          hintStyle: AppTextStyles.headingMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          filled: true,
          fillColor: AppColors.textfieldSurface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      ),
    );
  }
}
