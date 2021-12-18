import 'package:datenschutz_chatbot/challenges/challenge.dart';
import 'package:datenschutz_chatbot/challenges/gap_text_challenge.dart';
import 'package:datenschutz_chatbot/challenges/info_challenge.dart';
import 'package:datenschutz_chatbot/challenges/matching_challenge.dart';
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
  Stopwatch stopwatch = Stopwatch()..start();

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

      // Demo MatchingChallenge
      challenges.add(MatchingChallenge(const ["Was ist Botty", "Was ist der Spieler?", "DSGVO steht für..."], const ["Chatbot", "Mensch", "Datenschutz-Grundverordnung"], key: UniqueKey(),),);

      // Demo GapTextChallenge
      challenges.add(GapTextChallenge(const ["Botty ist ein", ", der heute seinen", "Schultag in der neuen Schule hat."], const ["Chatbot","Mensch","ersten", "letzten"], const ["Chatbot", "ersten"], 5, key: UniqueKey(),));


      // Demo InfoChallenges
      challenges.add(InfoChallenge(InfoChallenge.auntImage, "Hallo Botty! Ich freue mich, dich zu sehen!", key: UniqueKey()));
      challenges.add(InfoChallenge(InfoChallenge.bottyImage, "Hallo Meta! Schön, dass du da bist!!", key: UniqueKey()));

      challenges.add(QuizChallenge(
        "Wer kann identifizierbar sein? Wähle alle korrekten Antworten aus.",
        const ["Natürliche Person", "Natürliche Person", "Land", "Organisation"],
        const [0],
        5,
        false,
        key: UniqueKey(),
      ));
      // Important: Every challenge must be added with a unique "key" identifier so Flutter knows to refresh the layout as the challenges are removed!
      // challenges.add(const QuizChallenge("Wer kann identifizierbar sein? Wähle die korrekte Antwort aus.", ["Natürliche Person", "Unternehmen", "Land", "Organisation"], [0], 5, true, key: Key("2")));
      // challenges.add(const QuizChallenge("Wer kann identifizierbar sein? Wähle alle korrekten Antworten aus.", ["Natürliche Person", "Natürliche Person", "Land", "Organisation"], [0], 5, false, key: Key("3")));
      // challenges.add(const QuizChallenge("Wer kann identifizierbar sein? Wähle die korrekte Antwort aus.", ["Natürliche Person", "Unternehmen", "Land", "Organisation"], [0], 5, true, key: Key("4")));

      challenges.add(QuizChallenge(
          "Du gibst deine Adresse zur Zusendung einer einmalige Bestellungeines Online-Händler. Muss deine Adresse nach der Zusendung gelöscht werden?",
          const [
            "Nein, da der Online-Händler noch ein berechtigtes Interesse anmeinen Daten hat(z.B. für Werbezwecke)",
            "Nein, da du deine Zustimmung zur Verarbeitung deiner Daten gegeben hast und diese weiter besteht",
            "Ja, aber nach einer Haltefrist von 10 Jahren, da sie noch für steuerliche Zwecke benötigt werden",
            "Ja, unverzüglich, da der Zweck der Erhebung nicht mehr besteht"
          ],
          const [2],
          5,
          true,
          key: UniqueKey()));
      challenges.add(QuizChallenge("Kannst du durch einen Widerruf deiner Einwilligung die unverzügliche Löschung deiner Daten erwirken?",
          const ["Nein, da ich meine Einwilligung nicht widerrufen kann", "Ja, wenn sonst kein Recht die Verarbeitung meiner Daten rechtfertigt"], const [1], 5, true,
          key: UniqueKey()));
      challenges.add(QuizChallenge(
          "Du hast bei einem Gewinnspiel teilgenommen und dein Name wird als Gewinner auf Instagram veröffentlicht. Muss der Verantwortliche sich, wenn du die Löschung deiner Daten forderst, sich auch um die unverzügliche Löschung aller Links & Backups der Daten kümmern?",
          const [
            "Ja, er ist schließlich für die Daten verantwortlich",
            "Nein, das ist technisch nicht möglich",
            "Jein, er muss zumindest die Verantwortlichen der Links & Backups über die Löschaufforderung informieren, falls technisch möglich und angemessen",
            "Jein, er muss selbst, falls technisch möglich und angemessen, alle Links & Backups entfernen"
          ],
          const [2],
          5,
          true,
          key: UniqueKey()));

      challenges.add(QuizChallenge(
        "Welche Merkmalszuordnung zu einer Person könnte sie identifizierbar machen?",
        const [
          "Namen",
          "Kennnummer",
          "Standortdaten",
          "Online-Kennung (IP-Adresse)",
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
        const [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10],
        5,
        false,
        key: UniqueKey(),
      ));
      challenges.add(QuizChallenge(
        "Was muss dir bei der Erhebung deiner Daten alles mitgeteilt werden?",
        const [
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
        const [0, 1, 2, 3, 4, 5, 6, 10, 11],
        5,
        false,
        key: UniqueKey(),
      ));
      challenges.add(QuizChallenge(
        "Über was muss dir vom Verantwortlichen Auskunft gegeben werden, wenn du das willst?",
        const [
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
        const [0, 1, 2, 3, 4, 5, 6, 10],
        5,
        false,
        key: UniqueKey(),
      ));
      challenges.add(QuizChallenge(
        "Was wird alles unter Verarbeitung verstanden? ",
        const [
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
        const [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17],
        5,
        false,
        key: UniqueKey(),
      ));

      challenges.add(QuizChallenge(
        "Zur Datenverarbeitung ist die Einwilligung der betroffenen Person notwendig.",
        const ["richtig", "falsch"],
        const [0],
        5,
        true,
        key: UniqueKey(),
      ));
      challenges.add(QuizChallenge(
        "Die Datenverarbeitung ist erlaubt, falls sie zur Erfüllung eines Vertrages notwendig ist.",
        const ["richtig", "falsch"],
        const [0],
        5,
        true,
        key: UniqueKey(),
      ));
      challenges.add(QuizChallenge(
        "Die Datenverarbeitung ist nicht erlaubt, falls lebenswichtige Interessen zu schützen sind.",
        const ["richtig", "falsch"],
        const [1],
        5,
        true,
        key: UniqueKey(),
      ));
      challenges.add(QuizChallenge(
        "Die Datenverarbeitung ist erlaubt, falls sie für eine Aufgabe im privaten Interesse notwendig ist.",
        const ["richtig", "falsch"],
        const [1],
        5,
        true,
        key: UniqueKey(),
      ));
      challenges.add(QuizChallenge(
        "Die Datenverarbeitung ist erlaubt, falls ein berechtigtes Interesse der Verantwortlichen vorliegt, solange die Grundrechte nicht überwiegen..",
        const ["richtig", "falsch"],
        const [1],
        5,
        true,
        key: UniqueKey(),
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
                Text("Dein bisheriger Fortschritt geht verloren!"),
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
    p.setValue("challengeFastestComplete", stopwatch.elapsed.inSeconds);
    p.setValue("challengeTotalXP", p.getInt("challengeTotalXP")+5);
    Navigator.pop(context, true); // TODO: Return result https://docs.flutter.dev/cookbook/navigation/returning-data
  }
}
