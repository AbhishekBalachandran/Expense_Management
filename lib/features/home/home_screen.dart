import 'package:expense_manager/bloc/home/home_bloc.dart';
import 'package:expense_manager/core/storage/prefs_service.dart';
import 'package:expense_manager/core/theme/app_theme.dart';
import 'package:expense_manager/shared/transaction_tile.dart';
import 'package:expense_manager/shared/widgets/shimmer_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(HomeLoadEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading || state is HomeInitial) {
              return const SingleChildScrollView(child: ShimmerTile());
            }
            if (state is HomeError) {
              return Center(
                child: Text(state.message, style: AppTextStyles.bodyMedium),
              );
            }
            if (state is HomeLoaded) {
              return _HomeContent(state: state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({required this.state});

  final HomeLoaded state;
  static const int _recentLimit = 10;

  @override
  Widget build(BuildContext context) {
    final nickname = context.read<PrefsService>().getNickName() ?? '';
    final recentTransactions = state.transactions.length > _recentLimit
        ? state.transactions.sublist(0, _recentLimit)
        : state.transactions;
    return RefreshIndicator(
      onRefresh: () async {
        context.read<HomeBloc>().add(HomeLoadEvent());
      },
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                const Text('👋', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 6),
                Text('Welcome, $nickname!', style: AppTextStyles.headingMedium),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _SummaryCard(
                    label: 'Total Income',
                    amount: 90000,
                    isIncome: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _SummaryCard(
                    label: 'Total Expense',
                    amount: 36345,
                    isIncome: false,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const _MonthlyLimitCard(spent: 7324, limit: 10000),
            const SizedBox(height: 20),
            if (recentTransactions.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Center(
                  child: Text(
                    'No transactions yet.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentTransactions.length,
                itemBuilder: (context, index) {
                  final transaction = recentTransactions[index];
                  return TransactionTile(
                    transaction: transaction,
                    onDelete: () => context.read<HomeBloc>().add(
                      HomeDeleteTransactionEvent(transactionId: transaction.id),
                    ),
                  );
                },
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _MonthlyLimitCard extends StatelessWidget {
  const _MonthlyLimitCard({required this.spent, required this.limit});

  final double spent;
  final double limit;

  @override
  Widget build(BuildContext context) {
    final progress = (spent / limit).clamp(0.0, 1.0);
    final remaining = ((1 - progress) * 100).toStringAsFixed(0);
    final isExceeded = spent >= limit;
    final barColor = isExceeded ? AppColors.expense : AppColors.income;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        color: AppColors.cardSurface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.borderColor, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MONTHLY LIMIT', style: AppTextStyles.bodySmall),
          const SizedBox(height: 14),
          Text('₹$spent / ₹$limit', style: AppTextStyles.headingSmall),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppColors.primaryText,
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
          const SizedBox(height: 14),
          Text('$remaining% Remaining', style: AppTextStyles.bodySmall),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.isIncome,
  });

  final String label;
  final double amount;
  final bool isIncome;

  @override
  Widget build(BuildContext context) {
    final bg = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: isIncome ? AppColors.incomeGradient : AppColors.expenseGradient,
    );
    final icon = isIncome
        ? Icons.arrow_downward_rounded
        : Icons.arrow_upward_rounded;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.lg),
      decoration: BoxDecoration(
        gradient: bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTextStyles.bodySmall),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(icon, color: AppColors.primaryText, size: 18),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  '₹$amount',
                  style: AppTextStyles.headingLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
