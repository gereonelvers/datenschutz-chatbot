import 'package:auto_size_text/auto_size_text.dart';
import 'package:bubble/bubble.dart';
import 'package:datenschutz_chatbot/challenges/challenge.dart';
import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:datenschutz_chatbot/utility_widgets/challenge_result_notification.dart';
import 'package:flutter/material.dart';

/// Implementation of Challenge that presents gap text that needs to be filled with words from a list
class GapTextChallenge extends Challenge {
  final List<String> gapText; // List consisting of the elements of the gap text. A gap to insert a text from answerOptions is inserted between two items of this list
  final List<String> answerOptions; // List of all answer options
  final List<String> correctAnswers; // Ordered List of the correct answers
  final int difficulty; // Difficulty rating, could be used for challenge list generation

  const GapTextChallenge(this.gapText, this.answerOptions, this.correctAnswers, this.difficulty, {Key? key}) : super(key: key);

  @override
  _GapTextChallengeState createState() => _GapTextChallengeState();
}

class _GapTextChallengeState extends ChallengeState<GapTextChallenge> {
  @override
  void initState() {
    gapText = widget.gapText;
    answerOptions = widget.answerOptions;
    correctAnswers = widget.correctAnswers;
    difficulty = widget.difficulty;
    providedAnswers = List.generate(widget.correctAnswers.length, (index) => "   " + index.toString() + "   ");
    super.initState();
  }

  List<String> gapText = <String>[];
  List<String> answerOptions = <String>[];
  List<String> correctAnswers = <String>[];
  int difficulty = -1;
  List<int> currentlySelected = <int>[]; // List of currently selected fields
  List<String> providedAnswers = [];
  bool wasCorrect = false; // Flips to true if user checks correct answers
  bool hasSubmitted = false; // User may only submit once
  String buttonText = "Überprüfen";
  Color buttonColor = BottyColors.darkBlue;

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
        child: Column(children: [
          Flexible(
            flex: 2,
            child: Padding(
                padding: const EdgeInsets.fromLTRB(4,2,4,2),
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: Image.asset("assets/img/data-white.png", color: Colors.black, alignment: Alignment.centerLeft),
                )
            ),
          ),
          Expanded(
            flex: 7,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 8, 0),
              child: Align(alignment: Alignment.topRight, child: Bubble(
                  nip: BubbleNip.leftTop,
                  radius: const Radius.circular(20),
                  nipHeight: 20,
                  nipRadius: 2,
                  elevation: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(children: [
                      for (int i = 0; i < gapText.length; i++)
                        i < gapText.length - 1 // Makes sure that no input field is inserted after the last element of the gap text
                            ? Wrap(children: [
                          AutoSizeText(
                            gapText[i],
                          ),
                          DragTarget(
                            builder: (BuildContext context, List<Object?> candidateData, List<dynamic> rejectedData) {
                              return Chip(
                                backgroundColor: candidateData.isNotEmpty ? BottyColors.darkBlue : BottyColors.lightBlue,
                                label: Text(providedAnswers[i]),
                              );
                            },
                            onAccept: (item) {
                              setState(() {
                                providedAnswers[i] = item.toString();
                              });
                            },
                          )
                        ])
                            : AutoSizeText(gapText[i])
                    ]),

                  ),
                  ))),
            ),
          Expanded(
            flex: 2,
            child: Wrap(
              children: [
                for (var answer in answerOptions)
                  Draggable<String>(
                    dragAnchorStrategy: pointerDragAnchorStrategy,
                    data: answer,
                    feedback: FloatingActionButton.extended(
                      onPressed: () {},
                      label: Text(answer),
                      backgroundColor: BottyColors.darkBlue,
                    ),
                    child: AnswerOptionChip(answer: answer),
                  )
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child:
            Text("Vervöllständige den Text, indem du die Antworten auf die Felder ziehst", textAlign: TextAlign.center,),
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
                            child: Text(buttonText),
                            style: ButtonStyle(
                                backgroundColor: MaterialStateProperty.all<Color>(
                                  buttonColor,
                                ),
                                shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(15.0),
                                ))))),
                  ],
                ),
              ))
        ]),
      ),
    );
  }

  @override
  void submit() {
    if (!hasSubmitted) {
      wasCorrect = true;
      for (int i = 0; i < correctAnswers.length; i++) {
        if (correctAnswers[i] != providedAnswers[i]) {
          print("Wrong answer provided");
          wasCorrect = false;
        }
      }
      print("wasCorrect: " + wasCorrect.toString());
      setState(() {
        buttonText = "Weiter";
        if (wasCorrect) {
          buttonColor = Colors.green;
        } else {
          buttonColor = Colors.red;
        }
      });
      hasSubmitted = true;
    } else {
      // Dispatch notification to let ChallengeWrapper know of challenge result
      ChallengeResultNotification(wasCorrect).dispatch(context);
    }
  }
}

class AnswerOptionChip extends StatelessWidget {
  const AnswerOptionChip({
    Key? key,
    required this.answer,
  }) : super(key: key);

  final String answer;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
      child: Chip(
        label: Text(answer),
      ),
    );
  }
}
