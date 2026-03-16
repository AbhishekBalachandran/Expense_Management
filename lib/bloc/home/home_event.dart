part of 'home_bloc.dart';

abstract class HomeEvent {}

class HomeLoadEvent extends HomeEvent {}

class HomeAddTransactionEvent extends HomeEvent {
  HomeAddTransactionEvent({
    required this.amount,
    required this.note,
    required this.type,
    required this.categoryId,
    required this.categoryName,
  });
  final double amount;
  final String note;
  final String type;
  final String categoryId;
  final String categoryName;
}

class HomeDeleteTransactionEvent extends HomeEvent {
  HomeDeleteTransactionEvent({required this.transactionId});
  final String transactionId;
}
