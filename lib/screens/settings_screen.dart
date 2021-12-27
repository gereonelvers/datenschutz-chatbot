import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:datenschutz_chatbot/utility_widgets/progress_model.dart';
import 'package:flutter/material.dart';
import 'package:mailto/mailto.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:random_string/random_string.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    getInfo();
    super.initState();
  }
  late ProgressModel progress;

  String sessionID = ""; // Unique, auto-generated session ID for Rasa. Auto-generated if not present.
  String versionNumber = ""; // Current version and build number
  String started = "Started:\n";
  String messagedStarted = "messagedStarted:\n";
  String finished = "Finished:\n";
  String messagedFinished = "messagedFinished:\n";
  int currentChapter = -1;
  bool classroomToggle = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: BottyColors.darkBlue,),
      backgroundColor: BottyColors.blue,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        physics: const BouncingScrollPhysics(),
        children: [
          Material(
            type: MaterialType.card,
            elevation: 5,
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.only(left: 20, bottom: 20, top: 10, right: 20),
              width: double.infinity,
              child: Column(
                children: [
                  const Text(
                    "Botty",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      // color: Colors.white
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                    child: Text(
                      versionNumber,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
          Material(
            type: MaterialType.card,
            elevation: 5,
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.only(left: 20, bottom: 20, top: 10, right: 20),
              width: double.infinity,
              child: Row(
                children: [
                  Text("Spielst du in der Klasse?"),
                  Switch(value: classroomToggle, onChanged: (value){
                    setState(() {
                      classroomToggle = value;
                      progress.setValue("classroomToggle", value);
                    });
                  })
                ],
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
          Material(
            type: MaterialType.card,
            elevation: 5,
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.only(left: 20, bottom: 20, top: 10, right: 20),
              child: Column(
                children: [
                  const Text(
                    "\"Botty - der Datenschutz-Chatbot\" ist ein Projekt des Bachelor-Praktikums \n\"IT-basiertes Lernen gestalten\" des \ni17-Lehrstuhls an der TU München.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      // color: Colors.white
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  ),
                  Text(
                    "Es folgen einige technische Informationen, die uns beim finden von Fehlern helfen können:",
                    textAlign: TextAlign.center,
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  ),
                  Text(
                    "Rasa session-ID:\n" + sessionID,
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    started,
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    messagedStarted,
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    finished,
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    messagedFinished,
                    textAlign: TextAlign.left,
                  ),
                  Text(
                    "Current Chapter: "+currentChapter.toString(),
                    textAlign: TextAlign.left,
                  ),
                  ElevatedButton(onPressed: (){getInfo();}, child: const Text("force reload"))

                ],
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
          Material(
            type: MaterialType.card,
            elevation: 5,
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () { sendFeedback(); },
              child: Container(
                padding: const EdgeInsets.only(left: 20, bottom: 20, top: 10, right: 20),
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.feedback_outlined),
                    ),
                    Text("Gib uns Feedback!"),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Get sessionID from SharedPreferences, version number from PackageInfo
  getInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    progress = await ProgressModel.getProgressModel();
    started = "Started:\n";
    messagedStarted = "messagedStarted:\n";
    finished = "Finished:\n";
    messagedFinished = "messagedFinished:\n";
    setState(() {
      String s = progress.getString("sessionID");
      if (s==""){
        s = randomString(32);
        progress.setValue("sessionID", s);
      }
      classroomToggle = progress.getBool("classroomToggle");
      sessionID = s;
      versionNumber = "Version: v" + packageInfo.version + "+" + packageInfo.buildNumber;
      for(int i = 0; i<5;i++) {
        started += i.toString() + ":" + progress.getBool("started" + i.toString()).toString() + ", ";
        messagedStarted += i.toString() + ":" + progress.getBool("messagedStarted" + i.toString()).toString() + ", ";
        finished += i.toString() + ":" + progress.getBool("finished" + i.toString()).toString() + ", ";
        messagedFinished += i.toString() + ":" + progress.getBool("messagedFinished" + i.toString()).toString() + ", ";
        currentChapter = progress.getCurrentChapter();
      }
    });

  }

  sendFeedback() async {
    print("Trying...");
    final mailtoLink = Mailto(
      to: ['gereon.elvers@tum.de'],
      subject: 'Botty: Feedback',
    );
    await launch('$mailtoLink');
  }

}