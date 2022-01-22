import 'package:another_flushbar/flushbar.dart';
import 'package:datenschutz_chatbot/challenges/challenge_wrapper.dart';
import 'package:datenschutz_chatbot/screens/game_screen.dart';
import 'package:datenschutz_chatbot/screens/survey_screen.dart';
import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:datenschutz_chatbot/utility_widgets/progress_model.dart';
import 'package:datenschutz_chatbot/utility_widgets/scroll_pageview_notification.dart';
import 'package:datenschutz_chatbot/utility_widgets/update_progress_notification.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:url_launcher/url_launcher.dart';

import 'outro_survey_screen.dart';

/// this is is the game overview/map screen shown on the left of the primary PageView
class GameOverviewScreen extends StatefulWidget {
  const GameOverviewScreen({Key? key}) : super(key: key);

  @override
  _GameOverviewScreenState createState() => _GameOverviewScreenState();
}

class _GameOverviewScreenState extends State<GameOverviewScreen> with TickerProviderStateMixin {
  late ProgressModel progress;
  PanelController panelController = PanelController();
  double difficulty = 100;
  int currentChapter = 0;

  @override
  void initState() {
    initProgressModel();
    super.initState();
  }

  void initProgressModel() async {
    progress = await ProgressModel.getProgressModel();
    setState(() {
      int i = progress.getCurrentChapter();
      if (!progress.getBool("classroomToggle")) {
        i = -1;
      }
      currentChapter = i;
    });
  }

  List<String> chapterNames = [
    "die Start-Umfrage",
    "das Treffen mit Meta",
    "die Fahrt",
    "den ersten Schultag",
    "die Abschluss-Umfrage",
  ];

  List<String> bonusNames = [
    "Erneut mit Meta treffen",
    "Racing Game wiederholen",
    "Zurück zur Schule",
    "Weitere Informationen",
    "Botty teilen",
    "Feedback geben",
  ];

  List<String> gameDescriptions = [
    "Triff dich erneut mit Tante Meta um in 10 zufälligen Fragen dein Können unter Beweis zu stellen.",
    "Stell deine Fahrkünste erneut unter Beweis - neue Fragen, gleiche Strecke.",
    "Kehre zur Schule zurück und wiederhole Bottys ersten Schultag",
    "Vertiefende Informationen kannst du auf der Internetseite des Bundesbeauftragten für den Datenschutz und die Informationsfreiheit finden.",
    "Empfiehl Botty weiter und hilf deinen Freunden, mehr über Datenschutz zu lernen.",
    "Du hast einen Fehler gefunden oder möchtest uns einfach Feedback geben? Schreib uns!",
  ];

  List<Icon> bonusIcons = [
    const Icon(Icons.coffee),
    const Icon(Icons.emoji_transportation),
    const Icon(Icons.school),
    const Icon(Icons.launch),
    const Icon(Icons.share),
    const Icon(Icons.bug_report_outlined),
  ];

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
          controller: panelController,
          panel: Column(children: [
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                decoration: const BoxDecoration(
                  color: BottyColors.greyWhite,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.0),
                    topRight: Radius.circular(24.0),
                  ),
                ),
                padding: const EdgeInsets.only(left: 0, bottom: 0, top: 25, right: 0),
                height: 85,
                width: double.infinity,
                child: GestureDetector(
                  onTap: () {
                    panelController.isPanelOpen?panelController.close():panelController.open();
                  },
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
            ),
            Expanded(
              child: Container(
                color: BottyColors.greyWhite,
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  itemCount: bonusNames.length,
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
                          onTap: () => launchBonus(index),
                          child: Row(
                            children: [
                              SizedBox(height: 100, child: Padding(
                                padding: const EdgeInsets.fromLTRB(12,8,8,8),
                                child: bonusIcons[index],
                              )),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    children: [
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Text(
                                          bonusNames[index],
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
              child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: questBackgrounds.length,
                  padding: const EdgeInsets.fromLTRB(0, 50, 0, 130), // Making sure the last element isn't stuck behind the sliding panel
                  itemBuilder: (context, index) {
                    return GestureDetector(onTap: () => launchQuest(index), child: AspectRatio(
                      aspectRatio: 900/420,
                        child: index==currentChapter?questBackgroundsMarked[index]:questBackgrounds[index]));
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

  launchQuest(int index) async {
    bool started = progress.getBool("started" + index.toString());
    bool classroomToggle = progress.getBool("classroomToggle");
    if (index>currentChapter && classroomToggle) {
      await Flushbar(
        margin: const EdgeInsets.fromLTRB(15,32,15,10),
        borderRadius: BorderRadius.circular(30),
        backgroundColor: BottyColors.greyWhite,
        titleColor: Colors.black,
        messageColor: Colors.black,
        animationDuration: const Duration(milliseconds: 200),
        icon: Lottie.asset("assets/lottie/botty-float.json"),
        flushbarPosition: FlushbarPosition.TOP,
        title: 'Sorry!',
        message: "Du hast dieses Kapitel noch nicht freigeschaltet 🔜🤔",
        boxShadows: const [BoxShadow(color: Colors.grey, offset: Offset(0.0, 0.2), blurRadius: 10.0)],
        duration: const Duration(milliseconds: 1500),
      ).show(context);
    }
    else {
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Kapitel starten?'),
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(30))),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [if (started) Text("Möchtest du " + chapterNames[index] + " wiederholen?") else
                    Text("Möchtest du " + chapterNames[index] + " starten?")
                  ]),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Zurück', style: TextStyle(color: BottyColors.darkBlue)),
                ),
                TextButton(
                child: const Text('Start', style: TextStyle(color: BottyColors.darkBlue)),
                  // This call is async, meaning that once the player returns from the screen, returnToMainScreen() will be called
                  onPressed: () async {
                    if (!progress.getBool("started" + index.toString())) progress.setValue("started" + index.toString(), true);
                    Navigator.of(context).pop();
                    // Start appropriate quest
                    // TODO: Progress should only be incremented if chapter is actually finished!
                    switch (index) {
                      case 0: // Initial Survey
                        await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const IntroSurveyScreen())
                        );
                        if (progress.getBool("classroomToggle")) progress.setValue("finished" + index.toString(), true);
                        updateProgress();
                        break;
                      case 1: // Challenges
                        bool finished = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ChallengeWrapper(true)),
                        );
                        if (finished) {
                          if (progress.getBool("classroomToggle")) progress.setValue("finished" + index.toString(), true);
                        }
                        updateProgress();
                        break;
                      case 2: // Racing Game
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GameScreen(0)),
                        );
                        if (progress.getBool("classroomToggle")) progress.setValue("finished" + index.toString(), true);
                        updateProgress();
                        break;
                      case 3: // Naninovel RPG
                        progress.setValue("rpgStarted", true);
                        await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const GameScreen(1)),
                        );
                        if (progress.getBool("classroomToggle")) progress.setValue("finished" + index.toString(), true);
                        updateProgress();
                        break;
                      case 4: // Ending Survey
                        await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const OutroSurveyScreen())
                        );
                        if (progress.getBool("classroomToggle")) progress.setValue("finished" + index.toString(), true);
                        updateProgress();
                        break;
                    }
                  }
                ),
              ],
            );
          });
    }
  }

  // Called when the player just finished a chapter
  updateProgress() {
    UpdateProgressNotification().dispatch(context); // Tell Flutter to rebuild main PageView children the next time it sees them
    ScrollPageViewNotification(1).dispatch(context); // Tell the main PageView to scroll to the ChatScreen, causing a rebuild (to refresh progress)
  }

  launchBonus(int index) async {
    switch (index) {
      case 0:
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return const ChallengeWrapper(false);
            });
        break;
      case 1:
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return const GameScreen(0);
            });
        break;
      case 2:
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return const GameScreen(1);
            });
        break;
      case 3:
        await launch("https://www.bfdi.bund.de");
        break;
      case 4:
        await Share.share('Schau dir jetzt Botty, den Datenschutz-Chatbot an:\nhttps://botty-datenschutz.de', subject: 'Lade dir Botty runter ⬇️');
        break;
      case 5:
        await launch("https://botty-datenschutz.de/botty-app-feedback/");
        break;
    }
  }
}
