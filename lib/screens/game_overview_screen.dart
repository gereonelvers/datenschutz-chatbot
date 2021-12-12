import 'dart:ui';

import 'package:datenschutz_chatbot/challenges/challenge_wrapper.dart';
import 'package:datenschutz_chatbot/screens/game_screen.dart';
import 'package:datenschutz_chatbot/screens/intro_screen.dart';
import 'package:datenschutz_chatbot/screens/survey_screen.dart';
import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:datenschutz_chatbot/utility_widgets/progress_model.dart';
import 'package:datenschutz_chatbot/utility_widgets/quiz_dialog.dart';
import 'package:datenschutz_chatbot/utility_widgets/scroll_pageview_notification.dart';
import 'package:datenschutz_chatbot/utility_widgets/update_progress_notification.dart';
import 'package:flutter/material.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

/// this is is the game overview/list widget
class GameOverviewScreen extends StatefulWidget {
  const GameOverviewScreen({Key? key}) : super(key: key);

  @override
  _GameOverviewScreenState createState() => _GameOverviewScreenState();
}

class _GameOverviewScreenState extends State<GameOverviewScreen> with TickerProviderStateMixin {
  late ProgressModel progress;
  double difficulty = 100;
  int currentQuest = 0;

  @override
  void initState() {
    initProgressModel();
    super.initState();
  }

  void initProgressModel() async {
    progress = await ProgressModel.getProgressModel();
    setState(() {
      currentQuest = progress.getCurrent();
    });
  }

  // TODO: Replace with final chapter names
  List<String> chapterNames = [
    "Start-Survey",
    "Challenges/Duolingo",
    "Racing Game",
    "RPG",
    "Abschluss-Survey",
  ];
  List<String> demoNames = [
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

  // TODO: These load really slowly in the current implementation. Maybe need to replace them with pngs if that's not fixable via e.g. caching
  // List<SvgPicture> questBackgrounds = [
  //   SvgPicture.asset("assets/svg/map-item-0.svg"),
  //   SvgPicture.asset("assets/svg/map-item-1.svg"),
  //   SvgPicture.asset("assets/svg/map-item-2.svg"),
  //   SvgPicture.asset("assets/svg/map-item-3.svg"),
  //   SvgPicture.asset("assets/svg/map-item-4.svg"),
  // ];
  // List<SvgPicture> questBackgroundsMarked = [
  //   SvgPicture.asset("assets/svg/map-item-0-marker.svg"),
  //   SvgPicture.asset("assets/svg/map-item-1-marker.svg"),
  //   SvgPicture.asset("assets/svg/map-item-2-marker.svg"),
  //   SvgPicture.asset("assets/svg/map-item-3-marker.svg"),
  //   SvgPicture.asset("assets/svg/map-item-4-marker.svg"),
  // ];
  List<Image> questBackgrounds = [
    Image.asset("assets/img/map-item-0.png"),
    Image.asset("assets/img/map-item-1.png"),
    Image.asset("assets/img/map-item-2.png"),
    Image.asset("assets/img/map-item-3.png"),
    Image.asset("assets/img/map-item-4.png"),
  ];
  List<Image> questBackgroundsMarked = [
    Image.asset("assets/img/map-item-0-marked.png"),
    Image.asset("assets/img/map-item-1-marked.png"),
    Image.asset("assets/img/map-item-2-marked.png"),
    Image.asset("assets/img/map-item-3-marked.png"),
    Image.asset("assets/img/map-item-4-marked.png"),
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
                padding: const EdgeInsets.only(left: 0, bottom: 0, top: 25, right: 0),
                height: 80,
                width: double.infinity,
                child: const Text(
                  "Bonusinhalte",
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
                  itemCount: demoNames.length,
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
                            // TODO: Leaving these in to make content testing easier. Remove once no longer needed
                            if (index.toInt() == 0) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return QuizDialog(difficulty);
                                  });
                            } else if (index.toInt() == 1) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const IntroScreen()),
                              );
                            } else if (index.toInt() == 2) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const SurveyScreen()),
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
                                          demoNames[index],
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
          body: Container(
              color: const Color(0xFF99CC33),
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 90), // Making sure the last element isn't stuck behind the sliding panel
              child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: questBackgrounds.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(onTap: () => startQuest(index), child: AspectRatio(
                      aspectRatio: 900/420,
                        child: index==currentQuest?questBackgroundsMarked[index]:questBackgrounds[index]));
                  })),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24.0),
            topRight: Radius.circular(24.0),
          ),
          minHeight: 80.0,
        ),
      ),
    );
  }

  startQuest(int index) async {
    bool started = progress.getValue("started" + index.toString());
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Kapitel starten?'),
            content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [Text("Möchtest du \"" + chapterNames[index] + "\" starten?"), if (started) const Text("Du hast das Kapitel bereits gestartet") else const Text("Du hast das Kapitel noch nicht gestartet")]),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Zurück'),
              ),
              TextButton(
                // This call is async, meaning that once the player returns from the screen, returnToMainScreen() will be called
                onPressed: () async {
                  if (!progress.getValue("started" + index.toString())) progress.setValue("started" + index.toString(), true);
                  Navigator.of(context).pop();
                  // Start appropriate quest
                  // TODO: set up finish-state once screens work (for all except QuizDialog)
                  switch (index) {
                    case 0: // Initial Survey
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SurveyScreen())
                      );
                      if (!progress.getValue("finished" + index.toString())) progress.setValue("finished" + index.toString(), true);
                      updateProgress();
                      break;
                    case 1: // Challenges
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ChallengeWrapper(100)),
                      );
                      if (!progress.getValue("finished" + index.toString())) progress.setValue("finished" + index.toString(), true);
                      updateProgress();
                      break;
                    case 2: // Racing Game
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const GameScreen(3)),
                      );
                      if (!progress.getValue("finished" + index.toString())) progress.setValue("finished" + index.toString(), true);
                      updateProgress();
                      break;
                    case 3: // Naninovel RPG
                      await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GameScreen(4)),
                      // MaterialPageRoute(builder: (context) => const UnityScreen()),
                      );
                      if (!progress.getValue("finished" + index.toString())) progress.setValue("finished" + index.toString(), true);
                      updateProgress();
                      break;
                    case 4: // Ending Survey
                      await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const SurveyScreen())
                      );
                      if (!progress.getValue("finished" + index.toString())) progress.setValue("finished" + index.toString(), true);
                      updateProgress();
                      break;
                  }
                },
                child: const Text('Start'),
              ),
            ],
          );
        });
  }

  // Called when the player just finished a chapter
  updateProgress() {
    UpdateProgressNotification().dispatch(context); // Tell Flutter to rebuild main PageView children the next time it sees them
    ScrollPageViewNotification(1).dispatch(context); // Tell the main PageView to scroll to the ChatScreen, causing a rebuild (to refresh progress)
  }
}
