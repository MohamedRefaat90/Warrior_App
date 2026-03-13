// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_data_source.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductDataSourceAdapter extends TypeAdapter<ProductDataSource> {
  @override
  final typeId = 9;

  @override
  ProductDataSource read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ProductDataSource.openFoodFacts;
      case 1:
        return ProductDataSource.userManual;
      case 2:
        return ProductDataSource.ocrExtracted;
      case 3:
        return ProductDataSource.cached;
      default:
        return ProductDataSource.openFoodFacts;
    }
  }

  @override
  void write(BinaryWriter writer, ProductDataSource obj) {
    switch (obj) {
      case ProductDataSource.openFoodFacts:
        writer.writeByte(0);
      case ProductDataSource.userManual:
        writer.writeByte(1);
      case ProductDataSource.ocrExtracted:
        writer.writeByte(2);
      case ProductDataSource.cached:
        writer.writeByte(3);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductDataSourceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
