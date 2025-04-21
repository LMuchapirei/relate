// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'media_hive_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MediaHiveItemAdapter extends TypeAdapter<MediaHiveItem> {
  @override
  final int typeId = 2;

  @override
  MediaHiveItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MediaHiveItem(
      type: fields[0] as MediaHiveType,
      content: fields[1] as String,
      interactionId: fields[2] as String,
      locationType: fields[3] as LocationHiveType,
    );
  }

  @override
  void write(BinaryWriter writer, MediaHiveItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.interactionId)
      ..writeByte(3)
      ..write(obj.locationType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaHiveItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MediaHiveTypeAdapter extends TypeAdapter<MediaHiveType> {
  @override
  final int typeId = 0;

  @override
  MediaHiveType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return MediaHiveType.image;
      case 1:
        return MediaHiveType.voice;
      case 2:
        return MediaHiveType.video;
      case 3:
        return MediaHiveType.location;
      case 4:
        return MediaHiveType.pdf;
      default:
        return MediaHiveType.image;
    }
  }

  @override
  void write(BinaryWriter writer, MediaHiveType obj) {
    switch (obj) {
      case MediaHiveType.image:
        writer.writeByte(0);
        break;
      case MediaHiveType.voice:
        writer.writeByte(1);
        break;
      case MediaHiveType.video:
        writer.writeByte(2);
        break;
      case MediaHiveType.location:
        writer.writeByte(3);
        break;
      case MediaHiveType.pdf:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MediaHiveTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class LocationHiveTypeAdapter extends TypeAdapter<LocationHiveType> {
  @override
  final int typeId = 1;

  @override
  LocationHiveType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LocationHiveType.online;
      case 1:
        return LocationHiveType.local;
      default:
        return LocationHiveType.online;
    }
  }

  @override
  void write(BinaryWriter writer, LocationHiveType obj) {
    switch (obj) {
      case LocationHiveType.online:
        writer.writeByte(0);
        break;
      case LocationHiveType.local:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationHiveTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
