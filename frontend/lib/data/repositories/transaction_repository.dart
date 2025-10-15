import '../models/transaction_model.dart';
import '../sources/local/local_transaction_source.dart';
import '../sources/remote/remote_transaction_source.dart';
import '../sources/local/hive_transaction.dart';


class OfflineTransactionRepository {
  final LocalTransactionSource localSource;
  final RemoteTransactionSource remoteSource;

  OfflineTransactionRepository({
    required this.localSource,
    required this.remoteSource,
  });

  List<HiveTransaction> getAllLocal() {
    return localSource.getAll();
  }

  Future<void> addTransactionOffline(TransactionModel txn) async {
    final hiveTxn = HiveTransaction(
      id: txn.id,
      amount: txn.amount,
      currency: txn.currency,
      category: txn.category,
      description: txn.description,
      date: txn.date,
      isSynced: false,
      operationType: 'add',
    );
    await localSource.add(hiveTxn);
  }

  Future<void> updateTransactionOffline(int key, TransactionModel txn) async {
    final existing = localSource.getByKey(key);

    if (existing != null) {
      existing.amount = txn.amount;
      existing.currency = txn.currency;
      existing.category = txn.category;
      existing.description = txn.description;
      existing.isSynced = false;
      existing.operationType = 'update';
      await localSource.update(key, existing);
    } else {
      final hiveTxn = HiveTransaction.fromModel(
        txn,
        isSynced: false,
        operationType: 'update',
      );
      await localSource.add(hiveTxn);
    }
  }

  Future<void> deleteTransactionOffline(int key, {int? serverId}) async {
    final existing = localSource.getByKey(key);
    if (existing != null) {
      existing.isSynced = false;
      existing.operationType = 'delete';
      //existing.id = serverId ?? existing.id;
      await localSource.update(key, existing);
    } else {
      throw Exception('Local transaction not found');
    }
  }

  Future<void> syncTransactions() async {
    final allTxns = localSource.getAll(includeDeleted: true);
    final unsynced = allTxns.where((t) => !t.isSynced).toList();

    for (final t in unsynced) {
      try {
        if (t.operationType == 'add' || t.id == null) {
          if (t.operationType != 'delete') {
            final created = await remoteSource.createTransaction(t.toTransactionModel());
            t.id = created.id;
            t.isSynced = true;
            t.operationType = null;
            await localSource.update(t.key, t);
          } else {
            await localSource.delete(t.key);
          }
        } else if (t.operationType == 'update') {
          await remoteSource.updateTransaction(t.id!, t.toTransactionModel().toJson());
          t.isSynced = true;
          t.operationType = null;
          await localSource.update(t.key, t);
        } else if (t.operationType == 'delete') {
          if (t.id != null) {
            await remoteSource.deleteTransaction(t.id!);
          }
          await localSource.delete(t.key);
        }
      } catch (e) {
        continue;
      }
    }
  }

  Future<List<TransactionModel>> getAllTransactions(int userId) async {
    final localTxns = localSource.getAll(includeDeleted: true);
    final models = localTxns.map((t) => t.toTransactionModel()).toList();

    try {
      final remoteTxns = await remoteSource.fetchTransactions(userId: userId);

      final unsyncedLocalIds = localTxns
        .where((t) => !t.isSynced)
        .map((t) => t.id)
        .whereType<int>()
        .toSet();

      for (final txn in remoteTxns) {
        if (txn.id != null && unsyncedLocalIds.contains(txn.id)) continue;

        final existing = localSource.getByServerId(txn.id!);
        if (existing != null) {
          existing.amount = txn.amount;
          existing.currency = txn.currency;
          existing.category = txn.category;
          existing.description = txn.description;
          existing.date = txn.date;
          existing.isSynced = true;
          existing.operationType = null;
          await localSource.update(existing.key, existing);
        } else {
          await localSource.add(HiveTransaction.fromModel(txn, isSynced: true));
        }
      }
      return localSource.getAll(includeDeleted: false).map((t) => t.toTransactionModel()).toList();
    } catch (_) {
      return models;
    }
  }

  Future<TransactionModel?> getTransactionById(int id, {int? userId}) async {
    final localTxn = localSource.getAll(includeDeleted: true)
        .cast<HiveTransaction?>()
        .firstWhere((t) => t?.id == id, orElse: () => null);

    if (localTxn != null) {
      return localTxn.toTransactionModel();
    }

    if (userId != null) {
      try {
        final remoteTxn = await remoteSource.fetchTransactionById(id);

        final existing = localSource.getByServerId(remoteTxn.id!);
        if (existing != null) {
          existing.amount = remoteTxn.amount;
          existing.currency = remoteTxn.currency;
          existing.category = remoteTxn.category;
          existing.description = remoteTxn.description;
          existing.date = remoteTxn.date;
          existing.isSynced = true;
          existing.operationType = null;
          await localSource.update(existing.key, existing);
        } else {
          await localSource.add(HiveTransaction.fromModel(remoteTxn, isSynced: true));
        }
        return remoteTxn;
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}

extension HiveTransactionExtension on HiveTransaction {
  TransactionModel toTransactionModel() {
    return TransactionModel(
      id: id,
      amount: amount,
      currency: currency,
      category: category,
      description: description,
      date: date,
      isSynced: isSynced,
      localKey: key is int ? key as int : null,
    );
  }
}