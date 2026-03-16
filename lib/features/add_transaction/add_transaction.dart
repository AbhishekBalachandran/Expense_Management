import 'package:expense_manager/bloc/home/home_bloc.dart';
import 'package:expense_manager/core/theme/app_theme.dart';
import 'package:expense_manager/domain/entities/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AddTransaction extends StatefulWidget {
  const AddTransaction({super.key});

  @override
  State<AddTransaction> createState() => _AddTransactionState();
}

class _AddTransactionState extends State<AddTransaction> {
  final _noteController = TextEditingController();
  final _amountController = TextEditingController();
  String _type = 'debit';
  CategoryEntity? _selectedCategory;
  bool get _isValid =>
      _noteController.text.trim().isNotEmpty &&
      _amountController.text.trim().isNotEmpty &&
      double.tryParse(_amountController.text.trim()) != null &&
      _selectedCategory != null;

  @override
  void dispose() {
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void save(List<CategoryEntity> categories) {
    if (!_isValid) return;
    final amount = double.parse(_amountController.text.trim());
    final cat = _selectedCategory!;

    context.read<HomeBloc>().add(
      HomeAddTransactionEvent(
        amount: amount,
        note: _noteController.text.trim(),
        type: _type,
        categoryId: cat.id,
        categoryName: cat.name,
      ),
    );
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        final categories = state is HomeLoaded
            ? state.categories
            : <CategoryEntity>[];
        return SafeArea(
          child: Scaffold(
            body: Column(
              crossAxisAlignment: .start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add Transaction',
                        style: AppTextStyles.headingLarge,
                      ),
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: Text(
                          'Close',
                          style: AppTextStyles.headingSmall.copyWith(
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: .start,
                      children: [
                        _TypeToggle(
                          selectedType: _type,
                          onChanged: (t) => setState(() => _type = t),
                        ),
                        const SizedBox(height: 16),

                        _InputField(
                          controller: _noteController,
                          hint: 'Title',
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 12),
                        _InputField(
                          controller: _amountController,
                          hint: 'Amount  (₹)',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 20),
                        Text('CATEGORY', style: AppTextStyles.bodySmall),
                        const SizedBox(height: 10),
                        _CategoryChips(
                          categories: categories,
                          selected: _selectedCategory,
                          onSelected: (cat) =>
                              setState(() => _selectedCategory = cat),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.secondarySurface.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusMd,
                            ),
                            border: Border.all(
                              color: AppColors.income.withValues(alpha: 0.25),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: AppColors.primaryText,
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Everything you add here is saved only on your device.',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        GestureDetector(
                          onTap: _isValid ? () => save(categories) : null,
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
                              'Save',
                              style: AppTextStyles.button.copyWith(
                                color: _isValid
                                    ? AppColors.primaryText
                                    : AppColors.textDisabled,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CategoryChips extends StatelessWidget {
  const _CategoryChips({
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  final List<CategoryEntity> categories;
  final CategoryEntity? selected;
  final ValueChanged<CategoryEntity> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected = selected?.id == cat.id;
        return GestureDetector(
          onTap: () => onSelected(cat),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.md,
              vertical: AppDimensions.sm,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.textfieldSurface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              border: Border.all(
                color: isSelected ? Colors.blue : AppColors.borderColor,
                width: 1,
              ),
            ),
            child: Text(
              cat.name,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected
                    ? AppColors.primaryText
                    : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _InputField extends StatelessWidget {
  const _InputField({
    required this.controller,
    required this.hint,
    this.keyboardType = TextInputType.text,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppDimensions.inputFieldHeight,
      decoration: BoxDecoration(
        color: AppColors.textfieldSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        child: TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: AppTextStyles.bodyMedium,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeToggle extends StatelessWidget {
  const _TypeToggle({required this.selectedType, required this.onChanged});

  final String selectedType;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      ),
      child: Row(
        children: [
          _ToggleOption(
            label: 'Expense',
            isSelected: selectedType == 'debit',
            selectedColor: AppColors.income,
            onTap: () => onChanged('debit'),
          ),
          _ToggleOption(
            label: 'Income',
            isSelected: selectedType == 'credit',
            selectedColor: AppColors.income,
            onTap: () => onChanged('credit'),
          ),
        ],
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.selectedColor,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final Color selectedColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: isSelected ? selectedColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
          ),
          alignment: .center,
          child: Text(label, style: AppTextStyles.headingSmall),
        ),
      ),
    );
  }
}
