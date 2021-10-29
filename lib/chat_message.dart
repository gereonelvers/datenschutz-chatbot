import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

enum SenderType { user, bot }

/// this widget is used to show a single chat message
// TODO: Fix Hive mapping for proper data persistence
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
          Padding(
            padding: const EdgeInsets.fromLTRB(20,0,0,0),
            child: Align(
                alignment: Alignment.centerRight,
                child: DecoratedBox(
                  // chat bubble decoration
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      message,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
              ),
          )
          :
          // Layout if message is from bot
          Padding(
            padding: const EdgeInsets.fromLTRB(0,0,20,0),
            child: Align(
                alignment: Alignment.centerLeft,
                child: DecoratedBox(
                  // chat bubble decoration
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      message,
                      style: Theme.of(context)
                          .textTheme
                          .bodyText1!
                          .copyWith(color: Colors.black87),
                    ),
                  ),
                ),
              ),
          ),
    );
  }
}
