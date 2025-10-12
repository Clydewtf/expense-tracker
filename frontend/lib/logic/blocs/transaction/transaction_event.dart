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


class UpdateTransactionEvent extends TransactionsEvent {
  final int id;
  final Map<String, dynamic> updates;

  UpdateTransactionEvent(this.id, this.updates);
}

class DeleteTransactionEvent extends TransactionsEvent {
  final int id;
  final int? localKey;
  DeleteTransactionEvent({required this.id, this.localKey});
}