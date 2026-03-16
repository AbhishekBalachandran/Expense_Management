part of 'home_bloc.dart';

abstract class HomeState {}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  HomeLoaded({required this.transactions, required this.categories});

  final List<TransactionEntity> transactions;
  final List<CategoryEntity> categories;

  HomeLoaded copyWith({
    List<TransactionEntity>? transactions,
    List<CategoryEntity>? categories,
  }) {
    return HomeLoaded(
      transactions: transactions ?? this.transactions,
      categories: categories ?? this.categories,
    );
  }
}

class HomeError extends HomeState {
  HomeError({required this.message});
  final String message;
}
