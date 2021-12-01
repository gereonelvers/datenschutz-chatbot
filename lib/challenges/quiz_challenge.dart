import 'package:datenschutz_chatbot/challenges/challenge.dart';
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
    super.initState();
  }

  String question = "";
  List<String> answers = <String>[];
  List<int> correctAnswers = [];
  int difficulty = -1;
  List<int> currentlySelected = <int>[]; // List of currently selected fields
  bool hasSubmitted = false;
  String buttonText = "Überprüfen";
  Color buttonColor = const Color(0xff1c313a);
  bool singleChoice = true;

  quizChallenge(question, answers, correctAnswers, difficulty, singleChoice) {
    question = this.question;
    answers = this.answers;
    correctAnswers = this.correctAnswers;
    difficulty = this.difficulty;
    singleChoice = this.singleChoice;
  }

  @override
  Widget build(BuildContext context) {
    question = widget.question;
    answers = widget.answers;
    correctAnswers = widget.correctAnswers;
    difficulty = widget.difficulty;
    singleChoice = widget.singleChoice;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
        elevation: 15,
        color: const Color(0xfff5f5f5),
        child: Column(children: [
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(32, 0, 32, 0),
              child: Align(alignment: Alignment.center, child: Text(question, style: const TextStyle(color: Colors.black, fontSize: 28))),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Divider(
              color: Color(0xff455a64),
              thickness: 1,
              height: 20,
            ),
          ),
          Expanded(
            flex: 6,
            child: GridView.count(
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                crossAxisCount: 2,
                childAspectRatio: 5 / 3,
                children: List.generate(answers.length, (index) {
                  return Card(
                      color: currentlySelected.contains(index) ? buttonColor : Colors.white,
                      child: InkWell(
                          onTap: () {
                            updateSelection(index);
                          },
                          child: Center(
                              child: Text(
                            answers[index],
                            style: TextStyle(color: currentlySelected.contains(index) ? Colors.white : Colors.black),
                          ))));
                })),
          ),
          Expanded(
              flex: 2,
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
                            ))),
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
    for (int element in correctAnswers) {
      if (!currentlySelected.contains(element)) {
        isCorrect = false;
      }
    }
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
      ChallengeResultNotification(isCorrect).dispatch(context);
      //reset();
    }
  }

}
