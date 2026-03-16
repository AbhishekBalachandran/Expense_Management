import 'package:expense_manager/core/theme/app_theme.dart';
import 'package:expense_manager/domain/entities/transaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  final TransactionEntity transaction;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final amtColor = isCredit ? AppColors.income : AppColors.expense;
    final prefix = isCredit ? '+' : '-';
    final dateStr = DateFormat('dd MMM yyyy').format(transaction.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.iconSurface,
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: const Icon(
              Icons.shopping_cart,
              color: AppColors.primaryText,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.note,
                  style: AppTextStyles.headingSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(transaction.categoryName, style: AppTextStyles.bodyMedium),
              ],
            ),
          ),
          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                dateStr,
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$prefix₹${transaction.amount}',
                style: AppTextStyles.labelLarge.copyWith(
                  color: amtColor,
                  fontSize: 22,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),

          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(color: Colors.transparent),
              child: Center(
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AppColors.error,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
