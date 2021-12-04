import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 1)
enum SenderType {
  @HiveField(0)
  user,

  @HiveField(1)
  bot
}

/// this widget is used to show a single chat message
@HiveType(typeId: 0)
class ChatMessage extends StatelessWidget {
  @HiveField(0)
  final String message;

  @HiveField(1)
  final SenderType type;

  const ChatMessage(this.message, this.type, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: type == SenderType.user
          ?
          // Layout if message is from user
          Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                child: DecoratedBox(
                  // chat bubble decoration
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C313A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(
                            color: const Color(0xFFF5F5F5),
                          ),
                    ),
                  ),
                ),
              ),
            )
          :
          // Layout if message is from bot
          Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                child: DecoratedBox(
                  // chat bubble decoration
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      message,
                      style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.black87),
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
