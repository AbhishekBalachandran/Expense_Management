import 'package:expense_manager/bloc/home/home_bloc.dart';
import 'package:expense_manager/core/theme/app_theme.dart';
import 'package:expense_manager/shared/transaction_tile.dart';
import 'package:expense_manager/shared/widgets/shimmer_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TransactionListScreen extends StatelessWidget {
  const TransactionListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: .start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
              child: Text('Transactions', style: AppTextStyles.headingMedium),
            ),
            Expanded(
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading || state is HomeInitial) {
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: 8,
                      itemBuilder: (_, _) => const Padding(
                        padding: EdgeInsets.only(bottom: 8),
                        child: ShimmerTile(),
                      ),
                    );
                  }

                  if (state is HomeError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }

                  if (state is HomeLoaded) {
                    final transactions = state.transactions;

                    if (transactions.isEmpty) {
                      return Center(
                        child: Text(
                          'No transactions yet.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: transactions.length,
                      itemBuilder: (context, index) {
                        final transaction = transactions[index];
                        return TransactionTile(
                          transaction: transaction,
                          onDelete: () => context.read<HomeBloc>().add(
                            HomeDeleteTransactionEvent(
                              transactionId: transaction.id,
                            ),
                          ),
                        );
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
