import 'package:hive_flutter/hive_flutter.dart';
import '../../models/transaction_model.dart';

part 'hive_transaction.g.dart';


@HiveType(typeId: 0)
class HiveTransaction extends HiveObject {
  @HiveField(0)
  int? id;

  @HiveField(1)
  double amount;

  @HiveField(2)
  String currency;

  @HiveField(3)
  String category;

  @HiveField(4)
  String? description;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  bool isSynced;

  @HiveField(7)
  String? operationType;

  HiveTransaction({
    this.id,
    required this.amount,
    required this.currency,
    required this.category,
    this.description,
    required this.date,
    this.isSynced = false,
    this.operationType,
  });

  factory HiveTransaction.fromModel(TransactionModel m, {bool isSynced = false, String? operationType}) {
    return HiveTransaction(
      id: m.id,
      amount: m.amount,
      currency: m.currency,
      category: m.category,
      description: m.description,
      date: m.date,
      isSynced: isSynced,
      operationType: operationType,
    );
  }

  TransactionModel toModel() {
    final int? serverId = id;
    final int? localKey = isInBox ? (key as int?) : null;
    return TransactionModel(
      id: serverId ?? localKey,
      userId: null,
      amount: amount,
      currency: currency,
      category: category,
      description: description,
      date: date,
    );
  }
}