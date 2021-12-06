import 'package:flutter/material.dart';

abstract class Challenge extends StatefulWidget {
  const Challenge({Key? key}) : super(key: key);
}

// TODO: Enhance abstraction by adding other methods to this superclass as required
abstract class ChallengeState<T extends Challenge> extends State<T> {

  void submit();

}
