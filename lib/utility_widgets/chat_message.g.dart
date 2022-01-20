// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ChatMessageAdapter extends TypeAdapter<ChatMessage> {
  @override
  final int typeId = 0;

  @override
  ChatMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ChatMessage(
      fields[0] as String,
      fields[1] as SenderType,
      (fields[2] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ChatMessage obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.message)
      ..writeByte(1)
      ..write(obj.type)
      ..writeByte(2)
      ..write(obj.suggestions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SenderTypeAdapter extends TypeAdapter<SenderType> {
  @override
  final int typeId = 1;

  @override
  SenderType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SenderType.user;
      case 1:
        return SenderType.bot;
      case 2:
        return SenderType.padding;
      default:
        return SenderType.user;
    }
  }

  @override
  void write(BinaryWriter writer, SenderType obj) {
    switch (obj) {
      case SenderType.user:
        writer.writeByte(0);
        break;
      case SenderType.bot:
        writer.writeByte(1);
        break;
      case SenderType.padding:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SenderTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
