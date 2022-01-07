import 'package:auto_size_text/auto_size_text.dart';
import 'package:bubble/bubble.dart';
import 'package:datenschutz_chatbot/challenges/challenge.dart';
import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:datenschutz_chatbot/utility_widgets/challenge_result_notification.dart';
import 'package:flutter/material.dart';

/// Implementation of Challenge that presents a matching screen between two lists of statements
/// Idea: Left side is a questionStrings, right side is Draggables/DragTargets that swap when they are dragged over each other -> user needs to sort correctly
class MatchingChallenge extends Challenge {
  final List<String> questionStrings;
  final List<String> answerStrings;

  const MatchingChallenge(this.questionStrings, this.answerStrings, {Key? key}) : super(key: key);

  @override
  _MatchingChallengeState createState() => _MatchingChallengeState();
}

class _MatchingChallengeState extends ChallengeState<MatchingChallenge> {
  @override
  void initState() {
    questionStrings = widget.questionStrings.toList();
    correctAnswerStrings = widget.answerStrings.toList();
    answerStrings = widget.answerStrings.toList();
    answerStrings.shuffle();
    super.initState();
  }

  List<String> questionStrings = [];
  List<String> answerStrings = [];
  List<String> correctAnswerStrings = [];

  bool hasSubmitted = false;
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
            flex: 10,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
              child: Align(alignment: Alignment.topRight, child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                    itemCount: answerStrings.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Row(children: [
                        Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: AutoSizeText(questionStrings[index], maxLines: 10,),
                            )),
                        Expanded(
                          flex:1,
                          child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Draggable<int>(
                              feedback: FloatingActionButton.extended(onPressed: (){}, label: Text(answerStrings[index]), backgroundColor: BottyColors.darkBlue,), data: index,
                              child: DragTarget(builder: (BuildContext context, List<Object?> candidateData, List<dynamic> rejectedData) {
                                return Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    color: candidateData.isNotEmpty ? BottyColors.darkBlue : BottyColors.lightBlue,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Padding(
                                        padding: const EdgeInsets.all(6.0),
                                        child: AutoSizeText(answerStrings[index], style: const TextStyle(color: BottyColors.greyWhite), maxLines: 1,),
                                      ),
                                    )
                                );
                              },
                                onAccept: (int data) {
                                  setState(() {
                                    String temp = answerStrings[index];
                                    answerStrings[index] = answerStrings[data];
                                    answerStrings[data] = temp;
                                  });
                                },
                              ),
                            ),
                          ),
                        )

                      ]);
                    }),))),
            ),
          const Expanded(
            flex: 1,
              child: Center(child: Text("Ordne die Texte den richtigen Sätzen zu"))
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
    bool isCorrect = true;
    for(int i =0;i<correctAnswerStrings.length;i++){
      if (correctAnswerStrings[i] != answerStrings[i]) {
        isCorrect = false;
      }
    }

    if (!hasSubmitted) {
      setState(() {
        buttonText = "Weiter";
        if (isCorrect) {
          buttonColor = Colors.green;
        } else {
          buttonColor = Colors.red;
        }
      });
      hasSubmitted = true;
    } else {
      // Dispatch notification to let ChallengeWrapper know of challenge result
      ChallengeResultNotification(isCorrect).dispatch(context);
    }
  }
}
