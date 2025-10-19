// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_transaction.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveTransactionAdapter extends TypeAdapter<HiveTransaction> {
  @override
  final int typeId = 0;

  @override
  HiveTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveTransaction(
      id: fields[0] as int?,
      amount: fields[1] as double,
      currency: fields[2] as String,
      category: fields[3] as String,
      description: fields[4] as String?,
      date: fields[5] as DateTime,
      isSynced: fields[6] as bool,
      operationType: fields[7] as String?,
      type: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HiveTransaction obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.currency)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.date)
      ..writeByte(6)
      ..write(obj.isSynced)
      ..writeByte(7)
      ..write(obj.operationType)
      ..writeByte(8)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
