import 'package:expense_manager/data/local/category_database.dart';
import 'package:expense_manager/data/local/transaction_database.dart';
import 'package:expense_manager/domain/entities/category.dart';
import 'package:expense_manager/domain/entities/transaction.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final TransactionDatabase _transactionDatabase;
  final CategoryDatabase _categoryDatabase;

  HomeBloc({
    required TransactionDatabase transactionDatabase,
    required CategoryDatabase categoryDatabase,
  }) : _transactionDatabase = transactionDatabase,
       _categoryDatabase = categoryDatabase,
       super(HomeInitial()) {
    on<HomeLoadEvent>(_onLoad);
    on<HomeAddTransactionEvent>(_onAddTransaction);
    on<HomeDeleteTransactionEvent>(_onDeleteTransaction);
  }
  Future<void> _onLoad(HomeLoadEvent event, Emitter<HomeState> emit) async {
    emit(HomeLoading());
    try {
      final transactions = await _transactionDatabase.getAllTransactions();
      final categories = await _categoryDatabase.getActiveCategories();
      emit(HomeLoaded(transactions: transactions, categories: categories));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onAddTransaction(
    HomeAddTransactionEvent event,
    Emitter<HomeState> emit,
  ) async {
    final current = state;
    if (current is! HomeLoaded) return;
    try {
      final transaction = await _transactionDatabase.insert(
        amount: event.amount,
        note: event.note,
        type: event.type,
        categoryId: event.categoryId,
        categoryName: event.categoryName,
      );
      final updated = [transaction, ...current.transactions];
      emit(current.copyWith(transactions: updated));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<void> _onDeleteTransaction(
    HomeDeleteTransactionEvent event,
    Emitter<HomeState> emit,
  ) async {
    final current = state;
    if (current is! HomeLoaded) return;
    try {
      await _transactionDatabase.delete(event.transactionId);
      final updated = current.transactions
          .where((t) => t.id != event.transactionId)
          .toList();
      emit(current.copyWith(transactions: updated));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }
}
