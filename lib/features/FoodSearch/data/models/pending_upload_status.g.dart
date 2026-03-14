// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_upload_status.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingUploadStatusAdapter extends TypeAdapter<PendingUploadStatus> {
  @override
  final typeId = 8;

  @override
  PendingUploadStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PendingUploadStatus.pending;
      case 1:
        return PendingUploadStatus.uploading;
      case 2:
        return PendingUploadStatus.failed;
      default:
        return PendingUploadStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, PendingUploadStatus obj) {
    switch (obj) {
      case PendingUploadStatus.pending:
        writer.writeByte(0);
      case PendingUploadStatus.uploading:
        writer.writeByte(1);
      case PendingUploadStatus.failed:
        writer.writeByte(2);
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingUploadStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
