import 'package:flutter/material.dart';
import 'botty_colors.dart';

class ChatContactBar extends StatelessWidget {
  const ChatContactBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 50, bottom: 0, top: 40, right: 50),
      height: 100,
      width: double.infinity,
      child: Material(
        type: MaterialType.button,
        borderRadius: BorderRadius.circular(30),
        elevation: 5,
        color: BottyColors.greyWhite,
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {},
          borderRadius: BorderRadius.circular(30),
          child: Row(
            children: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(36, 4, 16, 4),
                  child: Image.asset(
                    "assets/img/data-white.png",
                    color: Colors.black,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Botty",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "⬤ online", // FIXME: The dot is broken on web. Fixable with custom font additions? Maybe add actual status indicator?
                    style: TextStyle(color: Colors.green),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}