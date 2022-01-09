import 'package:auto_size_text/auto_size_text.dart';
import 'package:bubble/bubble.dart';
import 'package:datenschutz_chatbot/challenges/challenge.dart';
import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:datenschutz_chatbot/utility_widgets/challenge_result_notification.dart';
import 'package:field_suggestion/field_suggestion.dart';
import 'package:flutter/material.dart';

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
  List<TextEditingController> textEditingControllers = [TextEditingController(), TextEditingController(), TextEditingController(), TextEditingController()];

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
                child: FieldSuggestion(
                  fieldDecoration: InputDecoration(
                    hintText: hintTexts[index], // optional
                    enabledBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: BottyColors.darkBlue),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide: BorderSide(color: BottyColors.darkBlue),
                    ),
                  ),
                  suggestionList: text.split(" "),
                  textController: textEditingControllers[index],
                  wOpacityAnimation: true,
                  boxStyle: SuggestionBoxStyle(
                    backgroundColor: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    padding: const EdgeInsets.fromLTRB(64, 0, 64, 0),
                    boxShadow: [
                      const BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: Offset(0, 0.2),
                      ),
                    ],
                  ),
                ),
              ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Text(
                "Trage die richtigen Begriffe aus dem Text in die Felder ein",
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
    if (!hasSubmitted) {
      setState(() {
        wasCorrect = true;
        for (int i = 0; i < correctAnswers.length; i++) {
          bool answerCorrect = false;
          if (textEditingControllers[i].text.trim() != "" && (correctAnswers[i].contains(textEditingControllers[i].text) || textEditingControllers[i].text.contains(correctAnswers[i]))) {
            answerCorrect = true;
          }
          if (!answerCorrect) {
            wasCorrect = false;
          }
        }
        hasSubmitted = true;
      });
      buttonText = "Weiter";
      if (wasCorrect) {
        buttonColor = Colors.green;
      } else {
        buttonColor = Colors.red;
      }
    } else {
      // Dispatch notification to let ChallengeWrapper know of challenge result
      ChallengeResultNotification(wasCorrect).dispatch(context);
    }
  }
}
