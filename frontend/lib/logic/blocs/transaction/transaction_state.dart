part of 'transaction_bloc.dart';


abstract class TransactionsState {}

class TransactionsInitial extends TransactionsState {}

class TransactionsLoading extends TransactionsState {}

class TransactionsLoaded extends TransactionsState {
  final List<TransactionModel> transactions;
  TransactionsLoaded(this.transactions);
}

class TransactionDetailLoaded extends TransactionsState {
  final TransactionModel transaction;
  TransactionDetailLoaded(this.transaction);
}

class TransactionDeleted extends TransactionsState {}

class TransactionsError extends TransactionsState {
  final String message;
  TransactionsError(this.message);
}