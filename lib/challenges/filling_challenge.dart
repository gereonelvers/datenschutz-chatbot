import 'package:another_flushbar/flushbar.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:datenschutz_chatbot/challenges/challenge.dart';
import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:datenschutz_chatbot/utility_widgets/challenge_result_notification.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Implementation of Challenge that asks the user to fill input fields
class FillingChallenge extends Challenge {
  final String text; // List consisting of the elements of the gap text. A gap to insert a text from answerOptions is inserted between two items of this list
  final List<String> correctAnswers; // Ordered List of the correct answers
  final int difficulty; // Difficulty rating, could be used for challenge list generation
  final List<String> hintTexts; // Text displayed as hints in text inputs

  const FillingChallenge(this.text, this.correctAnswers, this.hintTexts, this.difficulty, {Key? key}) : super(key: key);

  @override
  _FillingChallengeState createState() => _FillingChallengeState();
}

//TODO: Fix this!
class _FillingChallengeState extends ChallengeState<FillingChallenge> {
  List<String> answers = <String>[];
  List<String> hintTexts = <String>[];

  @override
  void initState() {
    text = widget.text;
    correctAnswers = widget.correctAnswers;
    difficulty = widget.difficulty;
    hintTexts = widget.hintTexts;
    for(int i=0;i<hintTexts.length;i++) {
      textEditingControllers.add(TextEditingController());
    }
    super.initState();
  }

  String text = "";
  List<String> correctAnswers = <String>[];
  int difficulty = -1;
  List<int> currentlySelected = <int>[]; // List of currently selected fields
  List<String> providedAnswers = [];
  bool wasCorrect = false; // Flips to true if user checks correct answers
  bool hasSubmitted = false; // User may only submit once
  String buttonText = "Überprüfen";
  Color buttonColor = BottyColors.darkBlue;
  List<TextEditingController> textEditingControllers = [];

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
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 24, 8, 4),
              child: AutoSizeText(
                text,
                minFontSize: 20,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(left: 24, right: 24, top: 8, bottom: 8),
              child: Divider(
                height: 5,
                color: BottyColors.darkBlue,
              ),
            ),
            for (int index = 0; index < textEditingControllers.length; index++)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: TextField(
                  enabled: !hasSubmitted,
                  style: TextStyle(color: hasSubmitted?Colors.amber:Colors.black),
                  decoration: InputDecoration(
                    hintText: hintTexts[index], // optional
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: BottyColors.darkBlue),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: BottyColors.darkBlue),
                    ),
                  ),
                  controller: textEditingControllers[index],
                ),
              ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                "Trage die richtigen Wörter aus dem Text in die Felder ein",
                textAlign: TextAlign.center,
              ),
            ),
            Align(
                alignment: Alignment.bottomCenter,
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
      ),
    );
  }

  @override
  void submit() {
    for (int i=0;i<textEditingControllers.length;i++) {
      if (!text.contains(textEditingControllers[i].text)&&!hasSubmitted) {
        Flushbar(
            margin: const EdgeInsets.fromLTRB(15,32,15,10),
            borderRadius: BorderRadius.circular(20),
            backgroundColor: BottyColors.greyWhite,
            titleColor: Colors.black,
            messageColor: Colors.black,
            animationDuration: const Duration(milliseconds: 200),
            icon: Lottie.asset("assets/lottie/botty-float.json"),
            flushbarPosition: FlushbarPosition.TOP,
            title: 'Achtung!',
            message: "Das "+i.toString()+". Feld enthält Text, der so nicht im Text vorkommt 😁",
            boxShadows: const [BoxShadow(color: Colors.grey, offset: Offset(0.0, 0.2), blurRadius: 10.0)],
            duration: const Duration(milliseconds: 2500),
            ).show(context);
        return;
      }
    }

    if (!hasSubmitted) {
      setState(() {
        wasCorrect = true;
        for (int i = 0; i < correctAnswers.length; i++) {
          print("correctAnswer:"+correctAnswers[i]+", provided answer: "+textEditingControllers[i].text);
          if (textEditingControllers[i].text.trim() == "" // Answer is incorrect, if it is empty,...
              || (!correctAnswers[i].contains(textEditingControllers[i].text) // ... or the input is not found in the correctAnswers or vice versa
                  && !textEditingControllers[i].text.contains(correctAnswers[i]))) {
            wasCorrect = false;
            print("Which was incorrect");
          }
          textEditingControllers[i].text=correctAnswers[i];
        }

        hasSubmitted = true;
        buttonText = "Weiter";
        buttonColor = wasCorrect?Colors.green:Colors.red;
      });
    } else {
      // Dispatch notification to let ChallengeWrapper know of challenge result
      ChallengeResultNotification(wasCorrect).dispatch(context);
    }
  }
}
