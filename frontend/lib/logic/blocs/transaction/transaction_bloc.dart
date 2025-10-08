import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/repositories/transaction_repository.dart';
part 'transaction_event.dart';
part 'transaction_state.dart';


class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final TransactionRepository transactionRepository;

  TransactionsBloc({required this.transactionRepository}) : super(TransactionsInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadTransactionById>(_onLoadTransactionById);
    on<AddTransactionEvent>(_onAddTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransactions(
      LoadTransactions event, Emitter<TransactionsState> emit) async {
    emit(TransactionsLoading());
    try {
      final txns = await transactionRepository.getTransactions();
      emit(TransactionsLoaded(txns));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  Future<void> _onLoadTransactionById(
      LoadTransactionById event, Emitter<TransactionsState> emit) async {
    emit(TransactionsLoading());
    try {
      final txn = await transactionRepository.getTransactionById(event.id);
      emit(TransactionDetailLoaded(txn));
    } catch (e) {
      emit(TransactionsError(e.toString()));
    }
  }

  Future<void> _onAddTransaction(
      AddTransactionEvent event, Emitter<TransactionsState> emit) async {
    if (state is TransactionsLoaded) {
      final current = List<TransactionModel>.from((state as TransactionsLoaded).transactions);
      try {
        final added = await transactionRepository.addTransaction(event.transaction);
        current.add(added);
        emit(TransactionsLoaded(current));
      } catch (e) {
        emit(TransactionsError(e.toString()));
      }
    }
  }

  Future<void> _onDeleteTransaction(
      DeleteTransactionEvent event, Emitter<TransactionsState> emit) async {
    if (state is TransactionsLoaded) {
      final current = List<TransactionModel>.from((state as TransactionsLoaded).transactions);
      try {
        await transactionRepository.deleteTransaction(event.id);
        current.removeWhere((txn) => txn.id == event.id);
        emit(TransactionsLoaded(current));
      } catch (e) {
        emit(TransactionsError(e.toString()));
      }
    }
  }
}