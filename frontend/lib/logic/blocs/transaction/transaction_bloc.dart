import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/transaction_model.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/transaction_repository.dart';
import '../../../data/sources/local/hive_transaction.dart';
part 'transaction_event.dart';
part 'transaction_state.dart';


class TransactionsBloc extends Bloc<TransactionsEvent, TransactionsState> {
  final OfflineTransactionRepository transactionRepository;
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

      await transactionRepository.syncTransactions();
      await transactionRepository.getAllTransactions(userId);

      final updatedLocal = transactionRepository.getAllLocal();
      emit(TransactionsLoaded(updatedLocal.map((t) => t.toTransactionModel()).toList()));
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
      final userId = await authRepository.getCurrentUserId();
      
      TransactionModel? txn;
      if (userId != null) {
        txn = await transactionRepository.getTransactionById(event.id, userId: userId);
      }

      if (txn == null) {
        final localTxn = transactionRepository.getAllLocal()
            .cast<HiveTransaction?>()
            .firstWhere(
              (t) => t?.id == event.id || t?.key == event.id,
              orElse: () => null,
            );

        if (localTxn != null) {
          txn = localTxn.toTransactionModel();
        }
      }

      if (txn != null) {
        emit(TransactionDetailLoaded(txn));
      } else {
        emit(TransactionsError('Transaction not found'));
      }
    } catch (e) {
      emit(TransactionsError('Failed to load transaction: ${e.toString()}'));
    }
  }

  Future<void> _onAddTransaction(
      AddTransactionEvent event, Emitter<TransactionsState> emit) async {
    try {
      final userId = await authRepository.getCurrentUserId();
      if (userId == null) throw Exception('User not logged in');
      
      await transactionRepository.addTransactionOffline(event.transaction);

      if (state is TransactionsLoaded) {
        final current = List<TransactionModel>.from((state as TransactionsLoaded).transactions);
        current.add(event.transaction);
        emit(TransactionsLoaded(current));
      }

      await transactionRepository.syncTransactions();
    } catch (e) {
      emit(TransactionsError('Failed to add transaction: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTransaction(
      UpdateTransactionEvent event, Emitter<TransactionsState> emit) async {
    emit(TransactionsLoading());
    try {
      final localTxn = transactionRepository.getAllLocal()
          .cast<HiveTransaction?>()
          .firstWhere(
            (t) => t?.id == event.id || t?.key == event.id,
            orElse: () => null,
          );

      if (localTxn == null) {
        emit(TransactionsError('Transaction not found locally'));
        return;
      }

      final updatedTxn = TransactionModel(
        id: localTxn.id,
        amount: event.updates['amount'] ?? localTxn.amount,
        currency: event.updates['currency'] ?? localTxn.currency,
        category: event.updates['category'] ?? localTxn.category,
        description: event.updates['description'] ?? localTxn.description,
        date: localTxn.date,
        type: event.updates['type'] ?? localTxn.type,
        isSynced: false,
      );
      await transactionRepository.updateTransactionOffline(localTxn.key as int, updatedTxn);

      if (state is TransactionsLoaded) {
        final current = List<TransactionModel>.from((state as TransactionsLoaded).transactions);
        final index = current.indexWhere((t) => t.id == event.id);
        if (index != -1) current[index] = updatedTxn;
        emit(TransactionsLoaded(current));
      }

      await transactionRepository.syncTransactions();
      emit(TransactionDetailLoaded(updatedTxn));
    } catch (e) {
      emit(TransactionsError('Failed to update transaction: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteTransaction(
      DeleteTransactionEvent event, Emitter<TransactionsState> emit) async {
    try {
      final localTxn = transactionRepository.getAllLocal()
          .cast<HiveTransaction?>()
          .firstWhere((t) => t?.id == event.id || t?.key == event.id, orElse: () => null);

      if (localTxn == null) {
        emit(TransactionsError('Transaction not found locally'));
        return;
      }
      await transactionRepository.deleteTransactionOffline(localTxn.key as int, serverId: localTxn.id);

      if (state is TransactionsLoaded) {
        final current = List<TransactionModel>.from((state as TransactionsLoaded).transactions);
        current.removeWhere((t) => t.id == event.id || t.localKey == localTxn.key);
        emit(TransactionsLoaded(current));
      }

      await transactionRepository.syncTransactions();
      emit(TransactionDeleted());
    } catch (e) {
      emit(TransactionsError('Failed to delete transaction: ${e.toString()}'));
    }
  }
}