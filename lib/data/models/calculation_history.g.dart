// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'calculation_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CalculationHistoryAdapter extends TypeAdapter<CalculationHistory> {
  @override
  final int typeId = 0;

  @override
  CalculationHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CalculationHistory(
      id: fields[0] as String,
      typeIndex: fields[1] as int,
      title: fields[2] as String,
      summary: fields[3] as String,
      input: (fields[4] as Map).cast<String, dynamic>(),
      result: (fields[5] as Map).cast<String, dynamic>(),
      createdAt: fields[6] as DateTime,
      syncedAt: fields[7] as DateTime?,
      memo: fields[8] as String? ?? '',
      isFavorite: fields[9] as bool? ?? false,
      updatedAt: fields[10] as DateTime?,
      deletedAt: fields[11] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, CalculationHistory obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.typeIndex)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.summary)
      ..writeByte(4)
      ..write(obj.input)
      ..writeByte(5)
      ..write(obj.result)
      ..writeByte(6)
      ..write(obj.createdAt)
      ..writeByte(7)
      ..write(obj.syncedAt)
      ..writeByte(8)
      ..write(obj.memo)
      ..writeByte(9)
      ..write(obj.isFavorite)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.deletedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CalculationHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
