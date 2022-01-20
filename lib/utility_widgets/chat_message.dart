import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'chat_message.g.dart';

@HiveType(typeId: 1)
enum SenderType {
  @HiveField(0)
  user,

  @HiveField(1)
  bot,

  @HiveField(2)
  padding
}

/// this widget is used to show a single chat message
@HiveType(typeId: 0)
class ChatMessage extends StatelessWidget {
  @HiveField(0)
  final String message;

  @HiveField(1)
  final SenderType type;

  @HiveField(2)
  final List<String> suggestions;

  const ChatMessage(this.message, this.type, this.suggestions, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Layout if message is from user
    if (type == SenderType.user) {
      return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: DecoratedBox(
                // chat bubble decoration
                decoration: BoxDecoration(
                  color: BottyColors.darkBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                      message, style: const TextStyle(color: Colors.white)
                  ),
                ),
              ),
            ),
          )
      );
    } else if (type == SenderType.bot) {
      // Layout if message is from bot
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: DecoratedBox(
              // chat bubble decoration
              decoration: BoxDecoration(
                color: BottyColors.greyWhite,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                    message, style: const TextStyle(color: Colors.black)
                ),
              ),
            ),
          ),
        ),
      );
    }
    // Layout if message padding
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 64, 16, 8),
      child: Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Text(
              message, style: const TextStyle(color: Colors.white)
          ),
        ),
      ),
    );


  }
}
