// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sale.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SaleItemAdapter extends TypeAdapter<SaleItem> {
  @override
  final int typeId = 5;

  @override
  SaleItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SaleItem(
      productName: fields[0] as String,
      quantity: fields[1] as int,
      unitPrice: fields[2] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SaleItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.productName)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.unitPrice);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SaleAdapter extends TypeAdapter<Sale> {
  @override
  final int typeId = 6;

  @override
  Sale read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Sale(
      saleId: fields[0] as String,
      date: fields[1] as DateTime,
      totalAmount: fields[2] as double,
      items: (fields[3] as List).cast<SaleItem>(),
      cashierName: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Sale obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.saleId)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.totalAmount)
      ..writeByte(3)
      ..write(obj.items)
      ..writeByte(4)
      ..write(obj.cashierName);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SaleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
