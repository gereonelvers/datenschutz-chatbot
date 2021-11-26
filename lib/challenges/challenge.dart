import 'package:flutter/material.dart';

enum ChallengeType { generic, quiz, multipleChoice, cloze } // Add new challenge types here

abstract class Challenge extends StatefulWidget {
  const Challenge({Key? key}) : super(key: key);
}

abstract class ChallengeState<T extends Challenge> extends State<T> {
  ChallengeType challengeType = ChallengeType.generic; // Should be overwritten!

  void submit();
  void reset();

}
