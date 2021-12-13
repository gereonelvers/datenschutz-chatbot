import 'package:auto_size_text/auto_size_text.dart';
import 'package:bubble/bubble.dart';
import 'package:datenschutz_chatbot/challenges/challenge.dart';
import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:datenschutz_chatbot/utility_widgets/challenge_result_notification.dart';
import 'package:flutter/material.dart';

class QuizChallenge extends Challenge {
  final String question;
  final List<String> answers;
  final List<int> correctAnswers;
  final int difficulty; // Difficulty rating, could be used for challenge list generation
  final bool singleChoice; // Boolean indicating if challenge should is singleChoice (false indicates multiple choice)

  const QuizChallenge(this.question, this.answers, this.correctAnswers, this.difficulty, this.singleChoice, {Key? key}) : super(key: key);

  @override
  _QuizChallengeState createState() => _QuizChallengeState();
}

class _QuizChallengeState extends ChallengeState<QuizChallenge> {
  @override
  void initState() {
    question = widget.question;
    answers = widget.answers;
    correctAnswers = widget.correctAnswers;
    difficulty = widget.difficulty;
    singleChoice = widget.singleChoice;
    super.initState();
  }

  String question = "";
  List<String> answers = <String>[];
  List<int> correctAnswers = [];
  int difficulty = -1;
  List<int> currentlySelected = <int>[]; // List of currently selected fields
  bool hasSubmitted = false;
  String buttonText = "Überprüfen";
  Color buttonColor = BottyColors.darkBlue;
  bool singleChoice = true;

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
            flex: 4,
            child: Column(
              children: [
                Flexible(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(4,2,4,2),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Image.asset("assets/img/data-white.png", color: Colors.black, alignment: Alignment.centerLeft,)),
                  ),
                ),
                Expanded(
                  flex: 6,
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
                          child: AutoSizeText(question, style: const TextStyle(color: Colors.black, fontSize: 24)),
                        ))),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Divider(
              color: BottyColors.blue,
              thickness: 1,
              height: 20,
            ),
          ),
          Expanded(
            flex: 6,
            child: GridView.count(
                physics: const BouncingScrollPhysics(),
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 2,
                childAspectRatio: 5 / 4,
                children: List.generate(answers.length, (index) {
                  return Card(
                      color: currentlySelected.contains(index) ? buttonColor : Colors.white,
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: InkWell(
                          borderRadius: BorderRadius.circular(15),
                          onTap: () {
                            updateSelection(index);
                          },
                          child: Center(
                              child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: AutoSizeText(
                              answers[index],
                              style: TextStyle(color: currentlySelected.contains(index) ? Colors.white : Colors.black),
                            ),
                          ))));
                })),
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

  void updateSelection(int selection) {
    setState(() {
      // Only update selection if user has not submitted yet
      if (!hasSubmitted) {
        if (currentlySelected.contains(selection)) {
          // If item is already selected, deselect it
          currentlySelected.remove(selection);
        } else {
          setState(() {
            if (singleChoice) {
              // If challenge is single choice, remove all other selected items
              currentlySelected.clear();
            }
            // Add item to selection
            currentlySelected.add(selection);
          });
        }
      }
    });
  }

  @override
  void submit() {
    bool isCorrect = true;
    // Check that all correct answers are selected
    for (int element in correctAnswers) {
      if (!currentlySelected.contains(element)) {
        isCorrect = false;
      }
    }
    // Check that no false answers are selected
    for (int element in currentlySelected) {
      if (!correctAnswers.contains(element)) {
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
