import 'package:datenschutz_chatbot/game_screen.dart';
import 'package:flutter/material.dart';

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
    "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.",
    "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.",
    "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.",
    "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.",
    "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua.",
    "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua."
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
        child: Stack(
          children: [
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(0, 80, 0, 10),
              itemCount: gameNames.length,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.fromLTRB(4, 0, 4, 0),
                  child: Card(
                    //color: const Color(0xFFE0E0E0),
                    color: const Color(0xFFF5F5F5),
                    child: InkWell(
                      splashColor: Colors.blue.withAlpha(30),
                      onTap: () {
                        // TODO: Launch correct unity app here
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => GameScreen(index)),
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
                                      style: const TextStyle(fontSize: 25),
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
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: const EdgeInsets.only(left: 50, bottom: 0, top: 20, right: 50),
                height: 50,
                width: double.infinity,
                child: Material(
                  type: MaterialType.button,
                  borderRadius: BorderRadius.circular(30),
                  elevation: 5,
                  color: const Color(0xfff5f5f5),
                  child: const Center(
                      child: Text(
                    "Spielesammlung",
                    style: TextStyle(
                      fontSize: 16,
                      // color: Colors.white
                    ),
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
