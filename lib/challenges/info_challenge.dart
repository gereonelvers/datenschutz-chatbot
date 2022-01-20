import 'package:bubble/bubble.dart';
import 'package:datenschutz_chatbot/challenges/challenge.dart';
import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:datenschutz_chatbot/utility_widgets/challenge_result_notification.dart';
import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

/// Implementation of Challenge that acts as a simple info screen (without any challenge at all)
class InfoChallenge extends Challenge {
  final Image character;
  final String info;

  const InfoChallenge(this.character, this.info, {Key? key}) : super(key: key);

  static final Image bottyImage = Image.asset("assets/img/data-white.png", color: Colors.black, alignment: Alignment.centerLeft);
  static final Image auntImage = Image.asset("assets/img/meta-grey.png", alignment: Alignment.centerRight);

  @override
  _InfoChallengeState createState() => _InfoChallengeState();
}

class _InfoChallengeState extends ChallengeState<InfoChallenge> {
  @override
  void initState() {
    character = widget.character;
    info = widget.info;
    super.initState();
  }

  String info = "";
  late Image character;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 15,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        color: BottyColors.greyWhite,
        child: Column(
          children: [
            Flexible(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4,2,4,2),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: character
                )
              ),
            ),
            Expanded(
              flex: 8,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 8, 0),
                child: Align(alignment: Alignment.topLeft, child: Bubble(
                    nip: BubbleNip.leftTop,
                    radius: const Radius.circular(20),
                    nipHeight: 20,
                    nipRadius: 2,
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child:
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: AnimatedTextKit(
                          animatedTexts: [
                            TyperAnimatedText(
                              info,
                              textStyle: const TextStyle(
                                fontSize: 24.0,
                              ),
                              speed: const Duration(milliseconds: 10),
                            ),
                          ],
                          totalRepeatCount: 1,
                          pause: const Duration(milliseconds: 10),
                          displayFullTextOnTap: true,
                          stopPauseOnTap: true,
                        ),
                      )
                        // AutoSizeText(info, style: const TextStyle(color: Colors.black, fontSize: 24)),
                    ))),
              ),
            ),
            Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: ElevatedButton(
                              onPressed: submit,
                              child: const Text("Weiter"),
                              style: ButtonStyle(
                                  backgroundColor: MaterialStateProperty.all<Color>(
                                    BottyColors.darkBlue,
                                  ),
                                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ))))),
                    ],
                  ),
                ))
          ],
        ),
      ),
    );
  }

  @override
  void submit() {
    // Dispatch notification to let ChallengeWrapper know of challenge result
    ChallengeResultNotification(true).dispatch(context);
  }
}
