// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VideoAdapter extends TypeAdapter<Video> {
  @override
  final int typeId = 0;

  @override
  Video read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Video(
      id: fields[0] as String,
      youtubeId: fields[1] as String,
      title: fields[2] as String,
      thumbnailUrl: fields[3] as String,
      durationSeconds: fields[4] as int,
      watchedSeconds: fields[5] as int,
      isCompleted: fields[6] as bool,
      resourceType: fields[7] as String?,
      content: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Video obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.youtubeId)
      ..writeByte(2)
      ..write(obj.title)
      ..writeByte(3)
      ..write(obj.thumbnailUrl)
      ..writeByte(4)
      ..write(obj.durationSeconds)
      ..writeByte(5)
      ..write(obj.watchedSeconds)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.resourceType)
      ..writeByte(8)
      ..write(obj.content);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VideoAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
