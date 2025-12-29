// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sales_report.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SalesReportAdapter extends TypeAdapter<SalesReport> {
  @override
  final int typeId = 7;

  @override
  SalesReport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SalesReport(
      reportId: fields[0] as String,
      cashierName: fields[1] as String,
      generatedDate: fields[2] as DateTime,
      totalSalesCount: fields[3] as int,
      totalAmount: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, SalesReport obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.reportId)
      ..writeByte(1)
      ..write(obj.cashierName)
      ..writeByte(2)
      ..write(obj.generatedDate)
      ..writeByte(3)
      ..write(obj.totalSalesCount)
      ..writeByte(4)
      ..write(obj.totalAmount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SalesReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
