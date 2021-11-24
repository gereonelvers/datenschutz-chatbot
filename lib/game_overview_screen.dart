import 'package:datenschutz_chatbot/game_screen.dart';
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
    "Erstes Spiel",
    "Zweites Spiel",
    "Drittes Spiel",
    "Viertes Spiel",
    "Fünftes Spiel",
    "Sechstes Spiel",
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
        color: const Color(0xFF799EB0),
        child: SlidingUpPanel(
          panel: Column(children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xfff5f5f5),
                  borderRadius: BorderRadius.only(
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
                color: const Color(0xfff5f5f5),
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  itemCount: gameNames.length,
                  scrollDirection: Axis.vertical,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                      child: Card(
                        //color: const Color(0xFFE0E0E0),
                        color: Colors.white,
                        child: InkWell(
                          splashColor: Colors.blue.withAlpha(30),
                          onTap: () {
                            // TODO: Launch correct unity app here
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => GameScreen(index)),
                              // MaterialPageRoute(builder: (context) => const UnityScreen()),
                            );
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
          body: Image.asset(
            "assets/img/map-placeholder.png", // Attribution: Designed by macrovector_official / Freepik
            fit: BoxFit.fitWidth,
            alignment: Alignment.bottomCenter,
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
}
