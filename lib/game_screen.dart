import 'package:flutter/material.dart';

class GameScreen extends StatefulWidget {
  final int gameID;

  const GameScreen(this.gameID, {Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  int gameID = -1;

  @override
  Widget build(BuildContext context) {
    gameID = widget.gameID;
    return Scaffold(
      body: SafeArea(
        child:
            Center(child: Text("Game Screen\n Game ID: " + gameID.toString())),
      ),
    );
  }

  test() {}
}
