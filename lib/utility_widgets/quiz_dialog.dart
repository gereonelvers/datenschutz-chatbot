import 'package:datenschutz_chatbot/challenges/challenge_wrapper.dart';
import 'package:flutter/material.dart';

class QuizDialog extends StatefulWidget {
  const QuizDialog(this.difficulty, {Key? key}) : super(key: key);

  final double difficulty;

  @override
  State<QuizDialog> createState() => _QuizDialogState();
}

class _QuizDialogState extends State<QuizDialog> {
  double difficulty = 100.0;

  @override
  void initState() {
    difficulty = widget.difficulty;
    super.initState();
  }

  _QuizDialogState();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Schwierigkeit wählen'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Slider(
            value: difficulty,
            onChanged: (double value) => setState(() => difficulty = value),
            min: 0,
            max: 200,
            //divisions: 10,
            activeColor: const Color(0xff1c313a),
          )
        ],
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Zurück'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChallengeWrapper(widget.difficulty.round())),
            );
          },
          child: const Text('Start'),
        ),
      ],
    );
  }
}