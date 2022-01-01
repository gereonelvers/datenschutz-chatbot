import 'package:flutter/material.dart';

import 'botty_colors.dart';

/// This class returns the content of the EmptyView displayed when the player has not received any messages yet
class MessageListEmptyView extends StatelessWidget {
  const MessageListEmptyView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(
          children: [
            ClipRRect(
              child: Container(
                child: Image.asset(
                  "assets/img/data-white.png",
                  height: 180,
                  width: 180,
                  color: BottyColors.darkBlue,
                ),
                color: Colors.white,
              ),
              borderRadius: BorderRadius.circular(45.0),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(8, 32, 8, 24),
              child: Text(
                "Noch keine Nachrichten.\nSchreib Botty doch einfach!",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            const Text("👈 Die Karte findest du links",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
            const Text("Deinen Fortschritt siehst du rechts 👉",
              style: TextStyle(color: Colors.white, fontSize: 14),
            )
          ],
          mainAxisAlignment: MainAxisAlignment.center,
        ));
  }
}