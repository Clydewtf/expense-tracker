import 'package:hive_flutter/hive_flutter.dart';
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

  Future<void> delete(int key) async {
    await _box.delete(key);
  }

  Future<void> clear() async {
    await _box.clear();
  }
}