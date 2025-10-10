import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
part 'transaction_event.dart';
part 'transaction_state.dart';


class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final TransactionRepository transactionRepository;
  final AuthRepository authRepository;

  TransactionsBloc({
    required this.transactionRepository,
    required this.authRepository,
  }) : super(TransactionsInitial()) {

    on<LoadTransactions>(_onLoadTransactions);
    on<LoadTransactionById>(_onLoadTransactionById);
    on<AddTransactionEvent>(_onAddTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
  }

  Future<void> _refreshTransactions(Emitter<TransactionsState> emit) async {
    emit(TransactionsLoading());
    try {
      final userId = await authRepository.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');

      final txns = await transactionRepository.getTransactions(userId: userId);
      emit(TransactionsLoaded(txns));
    } catch (e) {
      emit(TransactionsError('Failed to load transactions: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTransactions(
      LoadTransactions event, Emitter<TransactionsState> emit) async {
    await _refreshTransactions(emit);
  }

  Future<void> _onLoadTransactionById(
      LoadTransactionById event, Emitter<TransactionsState> emit) async {
    emit(TransactionsLoading());
    try {
      final txn = await transactionRepository.getTransactionById(event.id);
      emit(TransactionDetailLoaded(txn));
    } catch (e) {
      emit(TransactionsError('Failed to load transaction: ${e.toString()}'));
    }
  }

  Future<void> _onAddTransaction(
      AddTransactionEvent event, Emitter<TransactionsState> emit) async {
    try {
      final userId = await authRepository.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');
      
      final added = await transactionRepository.addTransaction(event.transaction);

      if (state is TransactionsLoaded) {
        final current =
            List<TransactionModel>.from((state as TransactionsLoaded).transactions);
        current.add(added);
        emit(TransactionsLoaded(current));
      } else {
        await _refreshTransactions(emit);
      }
    } catch (e) {
      emit(TransactionsError('Failed to add transaction: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTransaction(
      UpdateTransactionEvent event, Emitter<TransactionsState> emit) async {
    emit(TransactionsLoading());
    try {
      final updatedTxn = await transactionRepository.updateTransaction(event.id, event.updates);

      if (state is TransactionsLoaded) {
        final current = List<TransactionModel>.from((state as TransactionsLoaded).transactions);
        final index = current.indexWhere((t) => t.id == event.id);
        if (index != -1) current[index] = updatedTxn;
        emit(TransactionsLoaded(current));
      } else {
        emit(TransactionDetailLoaded(updatedTxn));
      }
    } catch (e) {
      emit(TransactionsError('Failed to update transaction: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteTransaction(
      DeleteTransactionEvent event, Emitter<TransactionsState> emit) async {
    try {
      await transactionRepository.deleteTransaction(event.id);
      
      if (state is TransactionsLoaded) {
        final current =
            List<TransactionModel>.from((state as TransactionsLoaded).transactions);
        current.removeWhere((txn) => txn.id == event.id);
        emit(TransactionsLoaded(current));
      } else {
        emit(TransactionDeleted());
      }
    } catch (e) {
      emit(TransactionsError('Failed to delete transaction: ${e.toString()}'));
    }
  }
}