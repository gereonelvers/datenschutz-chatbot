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
          title: Row(
            children: [
              IconButton(onPressed: showCancelDialog, icon: const Icon(Icons.close)),

              Flexible(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: LinearProgressIndicator(
                      minHeight: 8,
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
                                              onPressed: () {
                                                finishChallenges();
                                              },
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
      // challenges.add(const QuizChallenge("Wer kann identifizierbar sein? Wähle die korrekte Antwort aus.", ["Natürliche Person", "Unternehmen", "Land", "Organisation"], [0], 5, true, key: Key("2")));
      // challenges.add(const QuizChallenge("Wer kann identifizierbar sein? Wähle alle korrekten Antworten aus.", ["Natürliche Person", "Natürliche Person", "Land", "Organisation"], [0], 5, false, key: Key("3")));
      // challenges.add(const QuizChallenge("Wer kann identifizierbar sein? Wähle die korrekte Antwort aus.", ["Natürliche Person", "Unternehmen", "Land", "Organisation"], [0], 5, true, key: Key("4")));

      challenges.add(const QuizChallenge(
          "Du gibst deine Adresse zur Zusendung einer einmalige Bestellungeines Online-Händler. Muss deine Adresse nach der Zusendung gelöscht werden?",
          [
            "Nein, da der Online-Händler noch ein berechtigtes Interesse anmeinen Daten hat(z.B. für Werbezwecke)",
            "Nein, da du deine Zustimmung zur Verarbeitung deiner Daten gegeben hast und diese weiter besteht",
            "Ja, aber nach einer Haltefrist von 10 Jahren, da sie noch für steuerliche Zwecke benötigt werden",
            "Ja, unverzüglich, da der Zweck der Erhebung nicht mehr besteht"
          ],
          [2],
          5,
          true,
          key: Key("2")));
      challenges.add(const QuizChallenge("Kannst du durch einen Widerruf deiner Einwilligung die unverzügliche Löschung deiner Daten erwirken?",
          ["Nein, da ich meine Einwilligung nicht widerrufen kann", "Ja, wenn sonst kein Recht die Verarbeitung meiner Daten rechtfertigt"], [1], 5, true,
          key: Key("3")));
      challenges.add(const QuizChallenge(
          "Du hast bei einem Gewinnspiel teilgenommen und dein Name wird als Gewinner auf Instagram veröffentlicht. Muss der Verantwortliche sich, wenn du die Löschung deiner Daten forderst, sich auch um die unverzügliche Löschung aller Links & Backups der Daten kümmern?",
          [
            "Ja, er ist schließlich für die Daten verantwortlich",
            "Nein, das ist technisch nicht möglich",
            "Jein, er muss zumindest die Verantwortlichen der Links & Backups über die Löschaufforderung informieren, falls technisch möglich und angemessen",
            "Jein, er muss selbst, falls technisch möglich und angemessen, alle Links & Backups entfernen"
          ],
          [2],
          5,
          true,
          key: Key("4")));

      challenges.add(const QuizChallenge(
        "Welche Merkmalszuordnung zu einer Person könnte sie identifizierbar machen?",
        [
          "Namen",
          "Kennnummer",
          "Standortdaten",
          "Online-Kennung(IP-Adresse)",
          "physische Merkmale",
          "physiologischen Merkmal",
          "genetische Merkmale",
          "psychischen Merkmale",
          "wirtschaftliche Merkmale",
          "kulturelle Identität",
          "soziale Identität",
          "randomisierte Nummer",
          "fiktiver Avatar, den auch mehrere Spieler gleichzeitig spielen können"
        ],
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
        5,
        false,
        key: Key("5"),
      ));
      challenges.add(const QuizChallenge(
        "Was muss dir bei der Erhebung deiner Daten alles mitgeteilt werden?",
        [
          "Name und Kontakt des Verantwortlichen",
          "Kontakt des Datenschutzbeauftragten",
          "Zweck der Verarbeitung",
          "Empfänger",
          "Absicht des Verantwortlichen",
          "Dauer der Speicherung",
          "sämtliche Rechte",
          "technische Verarbeitungsweise",
          "Standort des Speichermediums",
          "Hardwareinfo des Verantwortlichen",
          "Kategorien der Daten",
          "wenn sie indirekt von dir erhoben werden"
        ],
        [0, 1, 2, 3, 4, 5, 6, 10, 11],
        5,
        false,
        key: Key("6"),
      ));
      challenges.add(const QuizChallenge(
        "Über was muss dir vom Verantwortlichen Auskunft gegeben werden, wenn du das willst?",
        [
          "Verarbeitungszweck",
          "Kategorien der Daten",
          "Dauer",
          "Empfänger",
          "bestehende Rechte",
          "Bestätigung, ob betreffende Daten verarbeitet werden",
          "Kopie der personenbezogenen Daten",
          "technische Verarbeitungsweise",
          "Standort des Speichermediums",
          "Hardwareinfo des Verantwortlichen",
          "Kategorien der Daten"
        ],
        [0, 1, 2, 3, 4, 5, 6, 10],
        5,
        false,
        key: Key("7"),
      ));
      challenges.add(const QuizChallenge(
        "Was wird alles unter Verarbeitung verstanden? ",
        [
          "Erheben",
          "Erfassen",
          "Organisation",
          "Ordnen",
          "Speicherung",
          "Anpassung",
          "Veränderung",
          "Auslesen",
          "Abfragen",
          "Verwendung",
          "Offenlegung",
          "Übermittlung",
          "Bereitstellung",
          "Abgleich",
          "Verknüpfung",
          "Einschränkung",
          "das Löschen",
          "Vernichtung"
        ],
        [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
        5,
        false,
        key: Key("8"),
      ));

      challenges.add(const QuizChallenge(
        "Zur Datenverarbeitung ist die Einwilligung der betroffenen Person notwendig.",
        ["richtig", "falsch"],
        [0],
        5,
        true,
        key: Key("9"),
      ));
      challenges.add(const QuizChallenge(
        "Die Datenverarbeitung ist erlaubt, falls sie zur Erfüllung eines Vertrages notwendig ist.",
        ["richtig", "falsch"],
        [0],
        5,
        true,
        key: Key("8"),
      ));
      challenges.add(const QuizChallenge(
        "Die Datenverarbeitung ist nicht erlaubt, falls lebenswichtige Interessen zu schützen sind.",
        ["richtig", "falsch"],
        [1],
        5,
        true,
        key: Key("10"),
      ));
      challenges.add(const QuizChallenge(
        "Die Datenverarbeitung ist erlaubt, falls sie für eine Aufgabe im privaten Interesse notwendig ist.",
        ["richtig", "falsch"],
        [1],
        5,
        true,
        key: Key("11"),
      ));
      challenges.add(const QuizChallenge(
        "Die Datenverarbeitung ist erlaubt, falls ein berechtigtes Interesse der Verantwortlichen vorliegt, solange die Grundrechte nicht überwiegen..",
        ["richtig", "falsch"],
        [1],
        5,
        true,
        key: Key("12"),
      ));
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

  showCancelDialog(){
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Abbrechen?"),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text("Dein bisheriges Fortschritt geht verloren!"),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Ja", style: TextStyle(color: BottyColors.darkBlue)),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: Text("Nein", style: TextStyle(color: BottyColors.darkBlue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Win", style: TextStyle(color: BottyColors.darkBlue)),
              onPressed: () {
                Navigator.of(context).pop();
                finishChallenges();
              },
            ),
          ],
        );
      },
    );
  }

  finishChallenges() async {
    ProgressModel p = await ProgressModel.getProgressModel();
    // TODO: These are placeholders. Fix!
    p.setValue("challengeMaxStreak", streak);
    p.setValue("challengeFastestComplete", 1);
    p.setValue("challengeTotalXP", 102);
    Navigator.pop(context, true); // TODO: Return result https://docs.flutter.dev/cookbook/navigation/returning-data
  }
}
