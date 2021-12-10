import 'package:flutter/material.dart';
import 'botty_colors.dart';

class ChatChip extends StatelessWidget {
  const ChatChip(this.message, {Key? key}) : super(key: key);
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
      child: Chip(
        elevation: 5,
        backgroundColor: BottyColors.darkBlue,
        label: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.white),
          ),
        ),
        //onPressed: () {},
      ),
    );
  }
}