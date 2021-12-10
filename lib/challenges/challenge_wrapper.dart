import 'package:datenschutz_chatbot/challenges/challenge.dart';
import 'package:datenschutz_chatbot/challenges/quiz_challenge.dart';
import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:datenschutz_chatbot/utility_widgets/challenge_result_notification.dart';
import 'package:datenschutz_chatbot/utility_widgets/progress_model.dart';
import 'package:flutter/material.dart';

class ChallengeWrapper extends StatefulWidget {
  final int difficulty;

  const ChallengeWrapper(this.difficulty, {Key? key}) : super(key: key);

  @override
  _ChallengeWrapperState createState() => _ChallengeWrapperState();
}

class _ChallengeWrapperState extends State<ChallengeWrapper> with TickerProviderStateMixin {
  int difficulty = 100; // Placeholder value for difficulty
  int streak = 0; // Streak count
  List<Challenge> challenges = <Challenge>[]; // Auto-generated list of challenges
  int challengeCount = 0; // Total number of challenges (used for progress indicator)
  bool generatedChallenges = false; // Notification valiable used to display placeholder if challenge generation takes longer than expected

  @override
  initState() {
    difficulty = widget.difficulty; // This is currently the only value passed through from the game menu screen
    generateChallenges(difficulty); // Generate challenges from inputs
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: BottyColors.darkBlue,
          title: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 0, 8, 0),
                  child: Text((challengeCount - challenges.length).toString() + "/" + challengeCount.toString()),
                ),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: LinearProgressIndicator(
                        // If not challenges are provided, provide 0.1 as challengeCount to prevent division by 0
                        value: ((challengeCount - challenges.length) / (challengeCount == 0 ? 0.1 : challengeCount)),
                        valueColor: AlwaysStoppedAnimation<Color>(BottyColors.lightestBlue),
                        backgroundColor: BottyColors.greyWhite,
                      ),
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(8, 0, 4, 0),
                  child: Icon(Icons.local_fire_department),
                ),
                Text(streak.toString())
              ],
            ),
          ),
        ),
        body: Container(
          color: BottyColors.darkBlue,
          child: NotificationListener<ChallengeResultNotification>(
              onNotification: (n) {
                updateChallenge(n.result);
                return n.result;
              },
              child: Center(
                  child: challenges.isEmpty
                      ? Center(
                          child: Stack(
                            children: [
                              const Center(
                                  child: Text(
                                "Du hast das Quiz beendet.\nGut gemacht! 🥳 ",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.white, fontSize: 24),
                              )),
                              Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                          child: ElevatedButton(
                                              onPressed: () {finishChallenges();},
                                              child: const Text("Weiter"),
                                              style: ButtonStyle(
                                                backgroundColor: MaterialStateProperty.all<Color>(
                                                  BottyColors.blue,
                                                ),
                                              ))),
                                    ],
                                  ),
                                ),
                              )
                            ],
                          ),
                        )
                      : challenges.first)),
        ));
  }

  generateChallenges(int difficulty) {
    setState(() {
      // TODO: Dynamically generate list of challenges here
      // Input: Difficulty, list of available questions
      // Output: List<Challenge> challenges
      // In the meantime, add three QuizChallenges as placeholder
      challenges.add(const QuizChallenge(
        "Wer kann identifizierbar sein? Wähle alle korrekten Antworten aus.",
        ["Natürliche Person", "Natürliche Person", "Land", "Organisation"],
        [0],
        5,
        false,
        key: Key("1"),
      ));
      // Important: Every challenge must be added with a unique "key" identifier so Flutter knows to refresh the layout as the challenges are removed!
      challenges.add(const QuizChallenge("Wer kann identifizierbar sein? Wähle die korrekte Antwort aus.", ["Natürliche Person", "Unternehmen", "Land", "Organisation"], [0], 5, true, key: Key("2")));
      challenges.add(const QuizChallenge("Wer kann identifizierbar sein? Wähle alle korrekten Antworten aus.", ["Natürliche Person", "Natürliche Person", "Land", "Organisation"], [0], 5, false, key: Key("3")));
      challenges.add(const QuizChallenge("Wer kann identifizierbar sein? Wähle die korrekte Antwort aus.", ["Natürliche Person", "Unternehmen", "Land", "Organisation"], [0], 5, true, key: Key("4")));
      // challenges.shuffle(Random()); // Shuffle challenges after generation
      challengeCount = challenges.length;
    });
  }

  updateChallenge(wasCorrect) {
    setState(() {
      if (wasCorrect) {
        streak++;
      } else {
        streak = 0;
        challenges.add(challenges.first);
        challengeCount++;
      }
      challenges.remove(challenges.first); // Remove current challenge
    });
  }

  finishChallenges() async {
    print("Starting exit ChallengeWrapper");
    ProgressModel progress = await ProgressModel.getProgressModel();
    progress.setValue("finished1", true);
    print("Exit ChallengeWrapper");
    Navigator.pop(context);
  }

}
