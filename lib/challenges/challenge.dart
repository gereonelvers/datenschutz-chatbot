import 'package:flutter/material.dart';

abstract class Challenge extends StatefulWidget {
  const Challenge({Key? key}) : super(key: key);
}

abstract class ChallengeState<T extends Challenge> extends State<T> {

  void submit();

}
