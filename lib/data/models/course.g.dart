// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CourseAdapter extends TypeAdapter<Course> {
  @override
  final int typeId = 1;

  @override
  Course read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Course(
      id: fields[0] as String,
      title: fields[1] as String,
      thumbnailUrl: fields[2] as String,
      sourceUrl: fields[3] as String,
      totalDuration: fields[4] as int,
      watchedDuration: fields[5] as int,
      isCompleted: fields[6] as bool,
      videos: (fields[7] as List).cast<Video>(),
      lastPlayedVideoId: fields[8] as String?,
      dateAdded: fields[9] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, Course obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.thumbnailUrl)
      ..writeByte(3)
      ..write(obj.sourceUrl)
      ..writeByte(4)
      ..write(obj.totalDuration)
      ..writeByte(5)
      ..write(obj.watchedDuration)
      ..writeByte(6)
      ..write(obj.isCompleted)
      ..writeByte(7)
      ..write(obj.videos)
      ..writeByte(8)
      ..write(obj.lastPlayedVideoId)
      ..writeByte(9)
      ..write(obj.dateAdded);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
