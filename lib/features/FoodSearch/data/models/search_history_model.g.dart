// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SearchHistoryModelAdapter extends TypeAdapter<SearchHistoryModel> {
  @override
  final int typeId = 12;

  @override
  SearchHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SearchHistoryModel(
      searchQuery: fields[0] as String,
      timestamp: fields[1] as DateTime,
      resultCount: fields[2] as int,
      searchType: fields[3] as SearchType,
    );
  }

  @override
  void write(BinaryWriter writer, SearchHistoryModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.searchQuery)
      ..writeByte(1)
      ..write(obj.timestamp)
      ..writeByte(2)
      ..write(obj.resultCount)
      ..writeByte(3)
      ..write(obj.searchType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SearchTypeAdapter extends TypeAdapter<SearchType> {
  @override
  final int typeId = 13;

  @override
  SearchType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SearchType.barcode;
      case 1:
        return SearchType.text;
      case 2:
        return SearchType.category;
      case 3:
        return SearchType.brand;
      default:
        return SearchType.barcode;
    }
  }

  @override
  void write(BinaryWriter writer, SearchType obj) {
    switch (obj) {
      case SearchType.barcode:
        writer.writeByte(0);
        break;
      case SearchType.text:
        writer.writeByte(1);
        break;
      case SearchType.category:
        writer.writeByte(2);
        break;
      case SearchType.brand:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
