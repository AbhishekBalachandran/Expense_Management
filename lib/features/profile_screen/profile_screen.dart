import 'package:expense_manager/bloc/sync/sync_bloc.dart';
import 'package:expense_manager/core/router/app_routes.dart';
import 'package:expense_manager/core/storage/prefs_service.dart';
import 'package:expense_manager/core/theme/app_theme.dart';
import 'package:expense_manager/data/local/category_database.dart';
import 'package:expense_manager/domain/entities/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _categoryController = TextEditingController();
  final _limitController = TextEditingController();
  List<CategoryEntity> _categories = [];
  bool _loadingCategories = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final cats = await context.read<CategoryDatabase>().getActiveCategories();
    if (mounted) {
      setState(() {
        _categories = cats;
        _loadingCategories = false;
      });
    }
  }

  Future<void> _addCategory() async {
    final name = _categoryController.text.trim();
    if (name.isEmpty) return;
    final cat = await context.read<CategoryDatabase>().insert(name);
    _categoryController.clear();
    setState(() => _categories = [..._categories, cat]);
  }

  Future<void> _deleteCategory(String id) async {
    await context.read<CategoryDatabase>().delete(id);
    setState(() => _categories = _categories.where((c) => c.id != id).toList());
  }

  void logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.cardSurface,
        title: Text('Log Out', style: AppTextStyles.headingSmall),
        content: Text(
          'Are you sure you want to log out?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.button.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              context.pop(context);
              await context.read<PrefsService>().clearAll();
              if (mounted) context.go(AppRoutes.onBoarding);
            },
            child: Text(
              'Log Out',
              style: AppTextStyles.button.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final prefs = context.read<PrefsService>();
    final nickname = prefs.getNickName() ?? '';
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 20),
            Text('Profile & Settings', style: AppTextStyles.headingMedium),
            const SizedBox(height: 24),
            //nickname
            _SectionHeading(label: 'NICKNAME'),
            const SizedBox(height: 12),
            NickNameField(nickname: nickname),
            const SizedBox(height: 16),
            CustomDivider(),
            const SizedBox(height: 16),
            _AlertLimitCard(
              controller: _limitController,
              currentLimit: 1000,
              onSet: () {
                FocusScope.of(context).unfocus();
              },
            ),
            const SizedBox(height: 16),
            CustomDivider(),
            const SizedBox(height: 16),
            _SectionHeading(label: 'CATEGORIES'),
            const SizedBox(height: 10),
            _CategoriesCard(
              controller: _categoryController,
              categories: _categories,
              isLoading: _loadingCategories,
              onAdd: _addCategory,
              onDelete: _deleteCategory,
            ),
            const SizedBox(height: 24),
            CustomDivider(),
            const SizedBox(height: 16),
            _SectionHeading(label: 'CLOUD SYNC'),
            const SizedBox(height: 16),
            _SyncCard(),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: logout,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(color: AppColors.borderColor, width: 1),
                ),
                alignment: Alignment.center,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Log Out',
                      style: AppTextStyles.headingSmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.power_settings_new_rounded,
                      color: AppColors.error,
                      size: 18,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SyncCard extends StatelessWidget {
  const _SyncCard();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SyncBloc, SyncState>(
      listener: (context, state) {
        if (state is SyncSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Sync complete!'),
              backgroundColor: AppColors.income,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
          );
        } else if (state is SyncFailure) {
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
        final isSyncing = state is SyncInProgress;
        final message = isSyncing
            ? (state).message
            : 'Sync and update data to the backend';

        return GestureDetector(
          onTap: isSyncing
              ? null
              : () => context.read<SyncBloc>().add(SyncStartEvent()),
          child: Container(
            padding: const EdgeInsets.all(AppDimensions.lg),
            decoration: BoxDecoration(
              color: AppColors.primarySurface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: AppColors.primary, width: 1),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Sync To Cloud', style: AppTextStyles.headingMedium),
                      const SizedBox(height: 4),
                      Text(message, style: AppTextStyles.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                isSyncing
                    ? const CircularProgressIndicator()
                    : const Icon(
                        Icons.cloud_upload_outlined,
                        color: Colors.white,
                        size: 26,
                      ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CustomDivider extends StatelessWidget {
  const CustomDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 2, color: AppColors.textfieldSurface);
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: AppTextStyles.labelLarge.copyWith(color: AppColors.primaryText),
    );
  }
}

class NickNameField extends StatelessWidget {
  const NickNameField({super.key, required this.nickname});
  final String nickname;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              nickname,
              style: AppTextStyles.headingMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              border: Border.all(color: AppColors.primaryText, width: 1),
            ),
            child: const Icon(
              Icons.edit_outlined,
              color: AppColors.primaryText,
              size: 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertLimitCard extends StatelessWidget {
  const _AlertLimitCard({
    required this.controller,
    required this.currentLimit,
    required this.onSet,
  });

  final TextEditingController controller;
  final double currentLimit;
  final VoidCallback onSet;

  @override
  Widget build(BuildContext context) {
    final formatter = '₹${currentLimit.toStringAsFixed(0)}';

    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.borderColor, width: 0.8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeading(label: 'ALERT LIMIT (₹)'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    child: TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: AppTextStyles.labelLarge.copyWith(
                        fontSize: 18,
                        color: AppColors.primaryText,
                      ),
                      cursorColor: AppColors.primary,
                      decoration: InputDecoration(
                        hintText: 'Amount  (₹)',
                        hintStyle: AppTextStyles.labelLarge.copyWith(
                          fontSize: 18,
                          color: AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onSet,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  alignment: Alignment.center,
                  child: Text('Set', style: AppTextStyles.button),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text('Current Limit: $formatter', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _CategoriesCard extends StatelessWidget {
  const _CategoriesCard({
    required this.controller,
    required this.categories,
    required this.isLoading,
    required this.onAdd,
    required this.onDelete,
  });

  final TextEditingController controller;
  final List<CategoryEntity> categories;
  final bool isLoading;
  final VoidCallback onAdd;
  final ValueChanged<String> onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                    child: TextField(
                      controller: controller,
                      style: AppTextStyles.bodyMedium,
                      cursorColor: AppColors.primary,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'New category Name',
                        hintStyle: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              GestureDetector(
                onTap: onAdd,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  ),
                  child: const Icon(
                    Icons.add_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          CustomDivider(),
          const SizedBox(height: 16),

          // category list
          if (isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 2,
              ),
            )
          else
            ...categories.map(
              (cat) =>
                  _CategoryRow(category: cat, onDelete: () => onDelete(cat.id)),
            ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({required this.category, required this.onDelete});

  final CategoryEntity category;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Text(
              category.name,
              style: AppTextStyles.labelLarge.copyWith(fontSize: 16),
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                border: Border.all(color: AppColors.error),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: AppColors.error,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
