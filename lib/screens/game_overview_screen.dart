import 'package:datenschutz_chatbot/challenges/challenge_wrapper.dart';
import 'package:datenschutz_chatbot/screens/game_screen.dart';
import 'package:datenschutz_chatbot/screens/intro_screen.dart';
import 'package:datenschutz_chatbot/screens/survey_screen.dart';
import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

/// this is is the game overview/list widget
class GameOverviewScreen extends StatefulWidget {
  const GameOverviewScreen({Key? key}) : super(key: key);

  @override
  _GameOverviewScreenState createState() => _GameOverviewScreenState();
}

class _GameOverviewScreenState extends State<GameOverviewScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  List<String> gameNames = [
    "Challenge/Quiz",
    "Intro Screen",
    "Survey Screen",
    "Unity Cube Demo",
    "RPG Demo",
    "Racing Game",
  ];
  List<String> gameDescriptions = [
    "Ich bin eine Kurzbeschreibung, welche final ca. 2-3 Sätze lang sein sollte. Bis die finalen Texte fertig sind, stehe ich hier als Platzhalter.",
    "Ich bin eine Kurzbeschreibung, welche final ca. 2-3 Sätze lang sein sollte. Bis die finalen Texte fertig sind, stehe ich hier als Platzhalter.",
    "Ich bin eine Kurzbeschreibung, welche final ca. 2-3 Sätze lang sein sollte. Bis die finalen Texte fertig sind, stehe ich hier als Platzhalter.",
    "Ich bin eine Kurzbeschreibung, welche final ca. 2-3 Sätze lang sein sollte. Bis die finalen Texte fertig sind, stehe ich hier als Platzhalter.",
    "Ich bin eine Kurzbeschreibung, welche final ca. 2-3 Sätze lang sein sollte. Bis die finalen Texte fertig sind, stehe ich hier als Platzhalter.",
    "Ich bin eine Kurzbeschreibung, welche final ca. 2-3 Sätze lang sein sollte. Bis die finalen Texte fertig sind, stehe ich hier als Platzhalter.",
  ];
  List<Image> gameImages = [
    Image.asset("assets/img/quiz-image.png"),
    Image.asset("assets/img/quiz-image.png"),
    Image.asset("assets/img/quiz-image.png"),
    Image.asset("assets/img/quiz-image.png"),
    Image.asset("assets/img/quiz-image.png"),
    Image.asset("assets/img/quiz-image.png")
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
        elevation: 5,
        type: MaterialType.card,
        color: BottyColors.lightestBlue,
        child: SlidingUpPanel(
          panel: Column(children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                decoration: BoxDecoration(
                  color: BottyColors.greyWhite,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                ),
                padding: const EdgeInsets.only(left: 0, bottom: 10, top: 10, right: 0),
                height: 80,
                width: double.infinity,
                child: const Text(
                  "Spielesammlung",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    // color: Colors.white
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: BottyColors.greyWhite,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  itemCount: gameNames.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                      child: Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        color: Colors.white,
                        child: InkWell(
                          splashColor: Colors.blue.withAlpha(30),
                          borderRadius: BorderRadius.circular(30),
                          onTap: () {
                            // print("Opening screen with index: " + index.toString());
                            // TODO: Move this to the right place & make it pretty
                            if (index.toInt() == 0) {
                              loadQuiz();
                            } else if (index.toInt() == 1) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => IntroScreen()),
                              );
                            } else if (index.toInt() == 2) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => SurveyScreen()),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => GameScreen(index)),
                                // MaterialPageRoute(builder: (context) => const UnityScreen()),
                              );
                            }
                          },
                          child: Row(
                            children: [
                              SizedBox(height: 100, child: gameImages[index]),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          gameNames[index],
                                          style: const TextStyle(fontSize: 20),
                                        ),
                                      ),
                                      Text(
                                        gameDescriptions[index],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ]),
          // TODO: Replace with actual map
          body: Image.asset(
            "assets/img/map-placeholder.png",
            fit: BoxFit.fitHeight,
            alignment: Alignment.topCenter,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
          minHeight: 80.0,
        ),
      ),
    );
  }

  double difficulty = 100;

  void loadQuiz() {
    // TODO: Make this work, pretty & useful :)
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Schwierigkeit wählen'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Slider(
                  value: difficulty,
                  onChanged: (double value) => setState(() => difficulty = value),
                  // TODO: setState() does not work to update UI here
                  min: 0,
                  max: 200,
                  //divisions: 10,
                  activeColor: const Color(0xff1c313a),
                )
              ],
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Zurück'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChallengeWrapper(difficulty.round())),
                  );
                },
                child: const Text('Start'),
              ),
            ],
          );
        });
  }
}
