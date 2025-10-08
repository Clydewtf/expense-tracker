part of 'transaction_bloc.dart';


abstract class TransactionsEvent {}

class LoadTransactions extends TransactionsEvent {}

class LoadTransactionById extends TransactionsEvent {
  final int id;
  LoadTransactionById(this.id);
}

class AddTransactionEvent extends TransactionsEvent {
  final TransactionModel transaction;
  AddTransactionEvent(this.transaction);
}

class DeleteTransactionEvent extends TransactionsEvent {
  final int id;
  DeleteTransactionEvent(this.id);
}