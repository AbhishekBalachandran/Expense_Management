import 'package:expense_manager/bloc/auth/auth_bloc.dart';
import 'package:expense_manager/core/router/app_routes.dart';
import 'package:expense_manager/core/theme/app_theme.dart';
import 'package:expense_manager/shared/widgets/custom_button.dart';
import 'package:expense_manager/shared/widgets/loading_overlay_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class NameScreen extends StatefulWidget {
  const NameScreen({super.key});

  @override
  State<NameScreen> createState() => _NameScreenState();
}

class _NameScreenState extends State<NameScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(validate);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void validate() {
    setState(() => _isValid = _controller.text.trim().isNotEmpty);
  }

  void submit() {
    if (!_isValid) return;
    context.read<AuthBloc>().add(SaveName(nickname: _controller.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is NameSavedState) {
          context.go(AppRoutes.home);
        } else if (state is AuthErrorState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return LoadingOverlay(
          isLoading: isLoading,
          child: Scaffold(
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 12,
                ),
                child: Column(
                  children: [
                    SizedBox(height: 48),
                    Row(
                      children: [
                        // wave hand
                        const Text('👋', style: TextStyle(fontSize: 28)),
                        // heading
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'What should we call you?',
                            style: AppTextStyles.headingLarge,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This name stays only on your device.',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 32),
                    NicknameField(
                      controller: _controller,
                      focusNode: _focusNode,
                      isValid: _isValid,
                    ),
                    const SizedBox(height: 20),
                    CustomButton(
                      isEnabled: _isValid,
                      onTap: submit,
                      text: "Continue",
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

class NicknameField extends StatelessWidget {
  const NicknameField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isValid,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isValid;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.inputFieldHeight,
      decoration: BoxDecoration(
        color: AppColors.textfieldSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.name,
              style: AppTextStyles.bodyMedium,
              decoration: InputDecoration(
                hintText: 'Eg: Abhishek',
                hintStyle: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textDisabled,
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
            ),
          ),

          // tick icon suffix
          if (isValid)
            const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Icon(
                Icons.check_circle_rounded,
                color: AppColors.income,
                size: 22,
              ),
            ),
        ],
      ),
    );
  }
}
