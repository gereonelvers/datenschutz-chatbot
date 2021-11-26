import 'package:datenschutz_chatbot/challenges/challenge.dart';
import 'package:datenschutz_chatbot/utility_widgets/challenge_result_notification.dart';
import 'package:flutter/material.dart';

class QuizChallenge extends StatefulWidget implements Challenge {
  String question;
  List<String> answers;
  int correctAnswer;
  int difficulty;

  QuizChallenge(this.question, this.answers, this.correctAnswer, this.difficulty, {Key? key}) : super(key: key);

  @override
  _QuizChallengeState createState() => _QuizChallengeState();
}

class _QuizChallengeState extends State<QuizChallenge> {
  @override
  void initState() {
    super.initState();
  }

  String question = "";
  List<String> answers = <String>[];
  int correctAnswer = -1;
  int difficulty = -1;
  int currentlySelected = -1;
  bool wasChecked = false;
  String buttonText = "Überprüfen";
  Color buttonColor = const Color(0xff1c313a);

  quizChallenge(question, answers, correctAnswer, difficulty) {
    question = this.question;
    answers = this.answers;
    correctAnswer = this.correctAnswer;
    difficulty = this.difficulty;
  }

  @override
  Widget build(BuildContext context) {
    question = widget.question;
    answers = widget.answers;
    correctAnswer = widget.correctAnswer;
    difficulty = widget.difficulty;
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
                      color: index == currentlySelected ? buttonColor : Colors.white,
                      child: InkWell(
                          onTap: () {
                            updateSelection(index);
                          },
                          child: Center(
                              child: Text(
                            answers[index],
                            style: TextStyle(color: index == currentlySelected ? Colors.white : Colors.black),
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

  void updateSelection(int index) {
    if (!wasChecked) {
      setState(() {
        currentlySelected = index;
      });
    }
  }

  ChallengeType challengeType = ChallengeType.quiz;

  void submit() {
    if (!wasChecked) {
      wasChecked = true;
      setState(() {
        buttonText = "Weiter";
        if (currentlySelected == correctAnswer) {
          buttonColor = Colors.green;
        } else {
          buttonColor = Colors.red;
        }
      });
    } else {
      // TODO: Submit back to ChallengeWrapper
      ChallengeResultNotification(currentlySelected == correctAnswer).dispatch(context);
      reset();
    }
  }

  void reset() {
    setState(() {
      currentlySelected = -1;
      wasChecked = false;
      buttonText = "Überprüfen";
      buttonColor = const Color(0xff1c313a);
    });
  }
}
