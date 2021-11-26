import 'package:flutter/material.dart';

enum ChallengeType { generic, quiz, multipleChoice, cloze } // Add new challenge types here

// FIXME: This is supposed to be the abstract class all challenges inherit from. Currently is isn't and the don't.
abstract class Challenge extends StatefulWidget {
  const Challenge({Key? key}) : super(key: key);
}

abstract class ChallengeState extends State<Challenge> {
  ChallengeType challengeType = ChallengeType.generic; // Should be overwritten!

  void submit();
  void reset();

}
