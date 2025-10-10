import 'package:hive_flutter/hive_flutter.dart';
import '../../models/transaction_model.dart';
import 'hive_transaction.dart';


class LocalTransactionSource {
  static const String boxName = 'transactions';
  late Box<HiveTransaction> _box;

  bool get isInitialized => _box.isOpen;

  HiveTransaction? getByKey(int key) => _box.get(key);

  HiveTransaction? getByServerId(int serverId) {
    try {
      return _box.values.firstWhere((t) => t.id == serverId);
    } catch (_) {
      return null;
    }
  }

  Future<void> init() async {
    _box = await Hive.openBox<HiveTransaction>(boxName);
  }

  List<HiveTransaction> getAll({bool includeDeleted = false}) {
    final items = _box.values.toList();
    if (includeDeleted) return items;
    return items.where((t) => t.operationType != 'delete').toList();
  }

  List<HiveTransaction> getPending() {
    return _box.values.where((t) => t.isSynced == false).toList();
  }

  Future<int> save(HiveTransaction txn) async {
    if (txn.isInBox) {
      await txn.save();
      return txn.key as int;
    } else {
      return await _box.add(txn);
    }
  }

  Future<int> add(HiveTransaction txn) async {
    return await save(txn);
  }

  Future<void> update(int key, HiveTransaction txn) async {
    await _box.put(key, txn);
  }

  Future<void> markDeleted(int key) async {
    final txn = _box.get(key);
    if (txn != null) {
      txn.operationType = 'delete';
      txn.isSynced = false;
      await txn.save();
    }
  }

  Future<void> delete(int key) async {
    await _box.delete(key);
  }

  Future<void> markSynced(int key, {TransactionModel? serverModel}) async {
    final txn = _box.get(key);
    if (txn == null) return;

    if (txn.operationType == 'delete') {
      // remove locally after remote delete confirmed
      await _box.delete(key);
      return;
    }

    // If server returned a canonical model (with server id / normalized fields),
    // map those values back to the local item.
    if (serverModel != null) {
      txn.id = serverModel.id;
      txn.amount = serverModel.amount;
      txn.currency = serverModel.currency;
      txn.category = serverModel.category;
      txn.description = serverModel.description;
      txn.date = serverModel.date;
    }

    txn.isSynced = true;
    txn.operationType = null;
    await txn.save();
  }

  Future<void> clear() async {
    await _box.clear();
  }
}