import 'dart:math';

import 'package:datenschutz_chatbot/challenges/challenge.dart';
import 'package:datenschutz_chatbot/challenges/gap_text_challenge.dart';
import 'package:datenschutz_chatbot/challenges/info_challenge.dart';
import 'package:datenschutz_chatbot/challenges/matching_challenge.dart';
import 'package:datenschutz_chatbot/challenges/quiz_challenge.dart';
import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:datenschutz_chatbot/utility_widgets/challenge_result_notification.dart';
import 'package:datenschutz_chatbot/utility_widgets/progress_model.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mccounting_text/mccounting_text.dart';

import 'animation_challenge.dart';
import 'filling_challenge.dart';

class ChallengeWrapper extends StatefulWidget {
  final bool isCampaign;

  const ChallengeWrapper(this.isCampaign, {Key? key}) : super(key: key);

  @override
  _ChallengeWrapperState createState() => _ChallengeWrapperState();
}

class _ChallengeWrapperState extends State<ChallengeWrapper> with TickerProviderStateMixin {
  bool isCampaign = true; // Placeholder value for difficulty
  int streak = 0; // Streak count
  List<Challenge> challenges = <Challenge>[]; // Auto-generated list of challenges
  int challengeCount = 0; // Total number of challenges (used for progress indicator)
  bool generatedChallenges = false; // Notification variable used to display placeholder if challenge generation takes longer than expected
  Stopwatch stopwatch = Stopwatch()..start();
  int time = 0;
  int skipVisible = 0; // The skip button is visible if more than 4 questions were answered incorrectly (can be same question 4 times)
  List<Challenge> challengeLibrary = [

  const IntroAnimationChallenge(),

  InfoChallenge(InfoChallenge.bottyImage, "Hallo Tante Meta! 👋", key: UniqueKey()),
  InfoChallenge(InfoChallenge.auntImage, "Hallo Botty! 🤗 Schön, dich zu sehen! Bist du gut angekommen? Freust du dich schon auf morgen? Wir haben uns ja schon so lange nicht gesehen! Du bist wirklich groß geworden! Lass uns loslegen!", key: UniqueKey()),
  InfoChallenge(InfoChallenge.bottyImage, "Ja! 😃 Womit wollen wir anfangen?", key: UniqueKey()),
  InfoChallenge(InfoChallenge.auntImage, "Mh, ich hab eine Idee… 🤔", key: UniqueKey()),
  InfoChallenge(InfoChallenge.auntImage, "Wir fangen mal ganz vorne an: Unter Datenschutz versteht man eine Menge an Gesetzen und Rechten, die die Privatsphäre von jedem von uns in der heutigen so automatisierten, modernen und computerisierten Welt schützen 🦾", key: UniqueKey()),
  InfoChallenge(InfoChallenge.auntImage, "In Deutschland 🇩🇪 ist Datenschutz mit der Datenschutz-Grundverordnung geregelt. Die gilt für jeden, der personenbezogene Daten verarbeitet.", key: UniqueKey()),
  InfoChallenge(InfoChallenge.auntImage, "Ich hab dir dazu mal ein paar Dinge mitgebracht! Schau mal 👀", key: UniqueKey()),

  FillingChallenge("„Einwilligung“ der betroffenen Person:\nJede freiwillig für den bestimmten Fall, in informierter Weise und unmissverständlich abgegebene Willensbekundung in Form einer Erklärung oder einer sonstigen eindeutigen bestätigenden Handlung zur Einverständnis der Verarbeitung ihrer personenbezogenen Daten",
    const ["betroffenen Person","freiwillig, für den bestimmten Fall, in informierter Weise, unmissverständlich","Willensbekundung, Erklärung, eindeutigen bestätigenden Handlung","zur Einverständnis der Verarbeitung ihrer personenbezogenen Daten"],
    const ["Wer?", "Wie?", "Was?", "Warum?"],
    5, key: UniqueKey(),),

  // Demo MatchingChallenge
  MatchingChallenge(const ["Die Person, auf die sich die Informationen in den personenbezogenen Daten bezieht und jede identifizierbare oder identifizierte Person, deren Daten erhoben und verarbeitet werden", " jede Person/ jede Einrichtung, die personenbezogene Daten für sich oder andere erhebt oder darüber entscheidet (der oder die was mit den Daten macht = Datenverarbeitung)", "jede Person/Einrichtung, außer der betroffenen Person, dem Verantwortlichen, dem Auftragsverarbeiter und den Personen, die unter der unmittelbaren Verantwortung des Verantwortlichen oder des Auftragsverarbeiters befugt sind, die personenbezogenen Daten zu verarbeiten"], const ["Betroffene Person", "Verantwortliche/r", "Dritte/r"], key: UniqueKey(),),

  // Demo GapTextChallenge
  GapTextChallenge(const ["Wähle Begriffe für die Lücken aus, nicht alle Begriffe gehören zu einer Lücke.", "hat das Recht, aus Gründen, die sich aus ihrer besonderen Situation ergeben,", "gegen die Verarbeitung","personenbezogener Daten Widerspruch einzulegen", "muss", "auf dieses Recht hingewiesen werden. Ausnahme: ", ""],
    const ["Die betroffene Person", "jederzeit", "sie betreffender", "ausdrücklich","indirekt(Daten, welche nicht beim Betroffenen selbst erhoben werden) erhobene Daten","Verwendung für Werbezwecke","Der Dritte","Der Dritte","Die betroffene Person","Der Bundesgerichtshof","Der Bundesgerichtshof","allgemeingültiger, auf Nachfrage", "Erfüllung einer öffentlichen Aufgabe","nicht","nicht","Der Verantwortliche","Der Verantwortliche", "am Anfang eines Monats"],
    const ["Die betroffene Person", "jederzeit", "sie betreffender", "Die betroffene Person", "ausdrücklich", "Erfüllung einer öffentlichen Aufgabe"],
    5, key: UniqueKey(),),
  GapTextChallenge(const ["Wähle Begriffe für die Lücken aus, nicht alle Begriffe gehören zu einer Lücke.", "hat das Recht, nicht einer ausschließlich auf einer", "Verarbeitung —","Profiling — beruhenden Entscheidung unterworfen zu werden, die ihr gegenüber rechtliche Wirkungentfaltet oder sie in ähnlicher Weise erheblich","."],
    const ["Die betroffene Person", "Der Verantwortliche", "automatisierten", "Der Dritte", "einschließlich", "beeinträchtigt"," Der Bundesgerichtshof","außer bei","unterstützt", "in Ausnahmen beim","analoger"],
    const ["Die betroffene Person", "automatisierten", "einschließlich","beeinträchtigt"],
    5, key: UniqueKey(),),

  QuizChallenge(
    "Wer kann identifizierbar sein?",
    const ["Unternehmen", "Natürliche Person", "Land", "Organisation"],
    const [1],
    5,
    true,
    key: UniqueKey(),
  ),
  QuizChallenge(
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
    key: UniqueKey()),
    QuizChallenge("Kannst du durch einen Widerruf deiner Einwilligung die unverzügliche Löschung deiner Daten erwirken?",
    const ["Nein, da ich meine Einwilligung nicht widerrufen kann", "Ja, wenn sonst kein Recht die Verarbeitung meiner Daten rechtfertigt"], const [1], 5, true,
    key: UniqueKey()),
  QuizChallenge(
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
    key: UniqueKey()),
  QuizChallenge(
    "Welche Merkmalszuordnung zu einer Person könnte sie identifizierbar machen?",
    const [
    "Namen",
    "Kennnummer",
    "Standortdaten",
    "Online-Kennung (IP-Adresse)",
    "physische Merkmale",
    "physiologische Merkmale",
    ],
    const [0, 1, 2, 3, 4, 5],
    5,
    false,
    key: UniqueKey(),
  ),
    QuizChallenge(
      "Und nochmal:\nWelche Merkmalszuordnung zu einer Person könnte sie identifizierbar machen?",
      const [
        "genetische Merkmale",
        "psychischen Merkmale",
        "wirtschaftliche Merkmale",
        "kulturelle Identität",
        "soziale Identität",
        "randomisierte Nummer",
      ],
      const [0, 1, 2, 3, 4],
      5,
      false,
      key: UniqueKey(),
    ),
  QuizChallenge(
    "Was muss dir bei der Erhebung deiner Daten alles mitgeteilt werden?",
    const [
      "alle Rechte",
      "technische Verarbeitungsweise",
      "Standort des Speichermediums",
      "Hardwareinfo des Verantwortlichen",
      "Kategorien der Daten",
      "wenn sie indirekt von dir erhoben werden",
    ],
    const [0, 4, 5],
    5,
    false,
    key: UniqueKey(),
  ),
    QuizChallenge(
      "Und nochmal: Was muss dir bei der Erhebung deiner Daten alles mitgeteilt werden?",
      const [
        "Name und Kontakt des Verantwortlichen",
        "Kontakt des Datenschutzbeauftragten",
        "Zweck der Verarbeitung",
        "Empfänger",
        "Absicht des Verantwortlichen",
        "Dauer der Speicherung",
      ],
      const [0, 1, 2, 3, 4, 5],
      5,
      false,
      key: UniqueKey(),
    ),
  QuizChallenge(
    "Über was muss dir vom Verantwortlichen Auskunft gegeben werden, wenn du das willst?",
    const [
    "Verarbeitungszweck",
    "Kategorien der Daten",
    "Dauer",
    "Empfänger",
    "bestehende Rechte",
    "Bestätigung, ob betreffende Daten verarbeitet werden",
    ],
    const [0, 1, 2, 3, 4, 5],
    5,
    false,
    key: UniqueKey(),
  ),
    QuizChallenge(
      "Und nochmal: Über was muss dir vom Verantwortlichen Auskunft gegeben werden, wenn du das willst?",
      const [
        "Kopie der personenbezogenen Daten",
        "technische Verarbeitungsweise",
        "Standort des Speichermediums",
        "Hardwareinfo des Verantwortlichen",
        "Kategorien der Daten"
      ],
      const [0, 4],
      5,
      false,
      key: UniqueKey(),
    ),
  QuizChallenge(
    "Was wird alles unter Verarbeitung verstanden?",
    const [
    "Erheben",
    "Erfassen",
    "Organisation",
    "Ordnen",
    "Speicherung",
    "Anpassung",
    ],
    const [0, 1, 2, 3, 4, 5],
    5,
    false,
    key: UniqueKey(),
  ),
    QuizChallenge(
      "Nochmal: Was wird alles unter Verarbeitung verstanden?",
      const [
        "Veränderung",
        "Auslesen",
        "Abfragen",
        "Verwendung",
        "Offenlegung",
        "Übermittlung",
      ],
      const [0, 1, 2, 3, 4, 5],
      5,
      false,
      key: UniqueKey(),
    ),
    QuizChallenge(
      "Und zum Abschluss: Was wird alles unter Verarbeitung verstanden?",
      const [
        "Bereitstellung",
        "Abgleich",
        "Verknüpfung",
        "Einschränkung",
        "das Löschen",
        "Vernichtung"
      ],
      const [0, 1, 2, 3, 4, 5],
      5,
      false,
      key: UniqueKey(),
    ),

  // Demo InfoChallenges
  InfoChallenge(InfoChallenge.bottyImage, "Danke, Tante Meta! Aber eine Frage habe ich dann doch noch...", key: UniqueKey()),
  InfoChallenge(InfoChallenge.bottyImage, "Darf das denn einfach jeder? Meine Daten verarbeiten?", key: UniqueKey()),
  InfoChallenge(InfoChallenge.auntImage, "Nein, natürlich nicht! Es gibt in der DSGVO sogenannte Erlaubnistatbestände, die das genau regeln.", key: UniqueKey()),
  InfoChallenge(InfoChallenge.auntImage, "Nach Artikel 6 der DSGVO ist eine Verarbeitung von personenbezogenen Daten nur dann rechtmäßig, wenn eine der folgenden 5 Bedingungen als Voraussetzung erfüllt ist.", key: UniqueKey()),
  InfoChallenge(InfoChallenge.auntImage, "Die erste Bedingung ist:\nDie betroffene Person hat ihre Einwilligung zu der Verarbeitung der sie betreffenden, personenbezogenen Daten für einen oder mehrere Zwecke erteilt.", key: UniqueKey()),
  InfoChallenge(InfoChallenge.auntImage, "Die zweite Bedigung ist:\nDie Verarbeitung ist für die Erfüllung eines Vertrags, dessen Vertragspartei die betroffene Person ist, oder zur Durchführung vorvertraglicher Maßnahmen erforderlich, die auf Anfrage der betroffenen Person erfolgen.", key: UniqueKey()),
  InfoChallenge(InfoChallenge.auntImage, "Die dritte Bedingung ist：\nDie Verarbeitung ist erforderlich, um lebenswichtige Interessen der betroffenen Person oder einer anderen natürlichen Person zu schützen. ", key: UniqueKey()),
  InfoChallenge(InfoChallenge.auntImage, "Die vierte Bedingung ist：\nDie Verarbeitung ist für die Wahrnehmung einer Aufgabe erforderlich, die im öffentlichen Interesse liegt oder in Ausübung öffentlicher Gewalt erfolgt, die dem Verantwortlichen übertragen wurde. ", key: UniqueKey()),
  InfoChallenge(InfoChallenge.auntImage, "Die fünfte Bedingung ist：\nDie Verarbeitung ist zur Wahrung der berechtigten Interessen des Verantwortlichen oder eines Dritten erforderlich, sofern nicht die Interessen oder Grundrechte oder Grundfreiheiten der betroffenen Person, die den Schutz personenbezogener Daten erfordern, überwiegen, insbesondere dann, wenn es sich bei der betroffenen Person um ein Kind handelt.", key: UniqueKey()),
  InfoChallenge(InfoChallenge.bottyImage, "Okay, also:", key: UniqueKey()),
  InfoChallenge(InfoChallenge.bottyImage, "Direkt Einwilligung, Vertrag, lebenswichtige Interessen oder öffentliches Interesse... richtig? 😁", key: UniqueKey()),
  InfoChallenge(InfoChallenge.auntImage, "Genau! Dann können wir ja mit einer kleinen Fragerunde beginnen.", key: UniqueKey()),
  InfoChallenge(InfoChallenge.auntImage, "Ich weiß, dass das erstmal nicht super spannend ist..", key: UniqueKey()),
  InfoChallenge(InfoChallenge.auntImage, "Aber Erlaubnistatbestände sind ein Hauptbestandteil der DSGVO. Du kannst das Thema erst wirklich gut beherrschen, wenn du sie wirklich verinnerlicht hast!", key: UniqueKey()),
  InfoChallenge(InfoChallenge.bottyImage, "Na dann, los geht's!", key: UniqueKey()),

  QuizChallenge(
    "Zur Datenverarbeitung ist die Einwilligung der betroffenen Person notwendig.",
    const ["richtig", "falsch"],
    const [0],
    5,
    true,
    key: UniqueKey(),
  ),
  QuizChallenge(
    "Die Datenverarbeitung ist erlaubt, falls sie zur Erfüllung eines Vertrages notwendig ist.",
    const ["richtig", "falsch"],
    const [0],
    5,
    true,
    key: UniqueKey(),
  ),
  QuizChallenge(
    "Die Datenverarbeitung ist nicht erlaubt, falls lebenswichtige Interessen zu schützen sind.",
    const ["richtig", "falsch"],
    const [1],
    5,
    true,
    key: UniqueKey(),
  ),
  QuizChallenge(
    "Die Datenverarbeitung ist erlaubt, falls sie für eine Aufgabe im privaten Interesse notwendig ist.",
    const ["richtig", "falsch"],
    const [1],
    5,
    true,
    key: UniqueKey(),
  ),
  QuizChallenge(
    "Die Datenverarbeitung ist erlaubt, falls ein berechtigtes Interesse der Verantwortlichen vorliegt, solange die Grundrechte nicht überwiegen..",
    const ["richtig", "falsch"],
    const [1],
    5,
    true,
    key: UniqueKey(),
  ),
  ];

  @override
  initState() {
    isCampaign = widget.isCampaign; // This is currently the only value passed through from the game menu screen
    generateChallenges(isCampaign); // Generate challenges from inputs
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
            padding: const EdgeInsets.only(top: 32),
            child: Row(
              children: [
                IconButton(onPressed: showCancelDialog, icon: const Icon(Icons.close)),
                Visibility(visible: skipVisible>4, child: IconButton(onPressed: skipChallenge, icon: const Icon(Icons.fast_forward_rounded))),
                Flexible(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      child: LinearProgressIndicator(
                        minHeight: 8,
                        // If no challenges are provided, provide 0.1 as challengeCount to prevent division by 0
                        value: ((challengeCount - challenges.length) / (challengeCount == 0 ? 0.1 : challengeCount)),
                        valueColor: const AlwaysStoppedAnimation<Color>(BottyColors.lightestBlue),
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
                              SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                child: Column(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0,0,0,0),
                                      child: Lottie.asset("assets/lottie/challenge-celebration.json", height: 210),
                                    ),
                                    const Align(
                                      alignment: Alignment.center,
                                      child: Padding(
                                        padding: EdgeInsets.fromLTRB(8,0,8,12),
                                        child: Text(
                                          "Du hast alle Fragen beantwortet! 🥳",
                                          textAlign: TextAlign.center,
                                          style: TextStyle(color: Colors.white, fontSize: 24),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(8,4,8,4),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        color: Colors.white,
                                        child: InkWell(
                                          splashColor: Colors.blue.withAlpha(30),
                                          borderRadius: BorderRadius.circular(30),
                                          child: Row(
                                            children: [
                                              const SizedBox(height: 100, child: Padding(
                                                padding: EdgeInsets.fromLTRB(12,2,12,2),
                                                child: Icon(Icons.local_fire_department, size: 48,),
                                              )),
                                            const Expanded(
                                              child: Text(
                                                "Deine Streak",
                                                style: TextStyle(fontSize: 18),
                                              ),
                                            ),
                                            Align(
                                              alignment: Alignment.centerRight,
                                              child: Padding(
                                                padding: const EdgeInsets.fromLTRB(4,4,24,4),
                                                child: McCountingText(
                                                  begin: 0,
                                                  end: streak.toDouble(),
                                                  style: const TextStyle(fontSize: 28),
                                                  duration: const Duration(seconds: 2),
                                                  curve: Curves.decelerate,
                                                ),
                                              ),
                                            ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(8,4,8,4),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        color: Colors.white,
                                        child: InkWell(
                                          splashColor: Colors.blue.withAlpha(30),
                                          borderRadius: BorderRadius.circular(30),
                                          child: Row(
                                            children: [
                                              const SizedBox(height: 100, child: Padding(
                                                padding: EdgeInsets.fromLTRB(12,2,12,2),
                                                child: Icon(Icons.timer, size: 48,),
                                              )),
                                              const Expanded(
                                                child: Text(
                                                  "Benötigte Zeit (in s)",
                                                  style: TextStyle(fontSize: 18),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(4,4,24,4),
                                                  child: McCountingText(
                                                    begin: 0,
                                                    end: time.toDouble(),
                                                    style: const TextStyle(fontSize: 28),
                                                    duration: const Duration(seconds: 2),
                                                    curve: Curves.decelerate,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(8,4,8,64),
                                      child: Card(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30),
                                        ),
                                        color: Colors.white,
                                        child: InkWell(
                                          splashColor: Colors.blue.withAlpha(30),
                                          borderRadius: BorderRadius.circular(30),
                                          child: Row(
                                            children: [
                                              const SizedBox(height: 100, child: Padding(
                                                padding: EdgeInsets.fromLTRB(12,2,12,2),
                                                child: Icon(Icons.celebration, size: 48,),
                                              )),
                                              const Expanded(
                                                child: Text(
                                                  "Verdiente XP",
                                                  style: TextStyle(fontSize: 18),
                                                ),
                                              ),
                                              Align(
                                                alignment: Alignment.centerRight,
                                                child: Padding(
                                                  padding: const EdgeInsets.fromLTRB(4,4,24,4),
                                                  child: McCountingText(
                                                    begin: 0,
                                                    end: ((isCampaign?360:120)-time)+streak*10.toDouble(),
                                                    //end: 5,
                                                    style: const TextStyle(fontSize: 28),
                                                    duration: const Duration(seconds: 3),
                                                    curve: Curves.decelerate,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
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

  generateChallenges(bool isCampaign) {
    setState(() {
      if (isCampaign) {
        for (Challenge element in challengeLibrary) {
          challenges.add(element);
        }
        // challenges.shuffle(Random()); // Shuffle challenges after generation
        challengeCount = challenges.length;
      } else {
        challenges.add(InfoChallenge(InfoChallenge.auntImage, "Großartig, lass uns loslegen!", key: UniqueKey()));
        Random r = Random();
        for(int i=0;i<11;i++){
          int j = 0;
          while(challengeLibrary[j] is InfoChallenge || challengeLibrary[j] is IntroAnimationChallenge || challenges.contains(challengeLibrary[j])){
            j = r.nextInt(challengeLibrary.length);
          }
          challenges.add(challengeLibrary[j]);
        }
        challengeCount = challenges.length;
      }
    });
  }

  updateChallenge(wasCorrect) {
    setState(() {
      print("Dismissing challenge, challengeCount:"+challengeCount.toString());
      if(challenges.length==1&&!wasCorrect){
        // This is an ugly fix to make sure that challenges reset properly if theres only one left
        challenges.insert(0,InfoChallenge(InfoChallenge.auntImage, "Gleich hast du's geschafft!"));
        challengeCount++;
      }
      if (wasCorrect) {
        streak++;
      } else {
        streak = 0;
        challenges.add(challenges.first);
        challengeCount++;
        skipVisible++;
      }
      challenges.remove(challenges.first); // Remove current challenge
      if(challenges.isEmpty) {
        time = stopwatch.elapsed.inSeconds;
      }
    });
  }

  showCancelDialog() {
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
              child: const Text("Ja", style: TextStyle(color: BottyColors.darkBlue)),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop(false);
              },
            ),
            TextButton(
              child: const Text("Nein", style: TextStyle(color: BottyColors.darkBlue)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  skipChallenge() {
    if(challenges.isNotEmpty){
      streak = 0;
      updateChallenge(true);
    }
  }

  finishChallenges() async {
    ProgressModel p = await ProgressModel.getProgressModel();
    p.setValue("challengeMaxStreak", streak);
    p.setValue("challengeFastestComplete", time);
    p.setValue("challengeTotalXP", p.getInt("challengeTotalXP") + ((isCampaign?360:120)-time)+streak*10);
    Navigator.pop(context, true);
  }

}
