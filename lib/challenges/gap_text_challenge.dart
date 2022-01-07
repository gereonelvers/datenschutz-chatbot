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
          Expanded(
            flex: 7,
            child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                      child: Wrap(children: getGapText())
                  ),
                )),
          ),
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              child: Wrap(
                children: [
                  for (var answer in answerOptions)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(8,0,8,0),
                      child: LongPressDraggable<String>(
                        delay: const Duration(milliseconds: 100),
                        dragAnchorStrategy: pointerDragAnchorStrategy,
                        data: answer,
                        feedback: FloatingActionButton.extended(
                          onPressed: () {},
                          label: AutoSizeText(answer, maxLines: 2,),
                          backgroundColor: BottyColors.darkBlue,
                        ),
                        child: AnswerOptionChip(answer: answer),
                      ),
                    )
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              "Vervöllständige den Text, indem du die Antworten auf die Felder ziehst",
              textAlign: TextAlign.center,
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
          wasCorrect = false;
        }
      }
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

  // Generate a list of widgets, alternating between gapText and DragTargets containing providedAnswers
  List<Widget> getGapText() {
    List<Widget> items = [];
    for (int i = 0; i < gapText.length; i++) {
      gapText[i].split(" ").forEach((element) { items.add(Padding(
        padding: const EdgeInsets.fromLTRB(0,12,0,0),
        child: Text(element+" ", style: const TextStyle(fontSize: 16),),
      )); }); // This is ugly but prevents issues with long text not wrapping properly
      if (i < gapText.length - 1) {
        items.add(Padding(
          padding: const EdgeInsets.fromLTRB(8,0,8,0),
          child: DragTarget(
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
          ),
        ));
      }
    }
    return items;
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
        label: AutoSizeText(answer, maxLines: 2,),
      ),
    );
  }
}
