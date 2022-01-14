import 'package:another_flushbar/flushbar.dart';
import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:datenschutz_chatbot/utility_widgets/progress_model.dart';
import 'package:datenschutz_chatbot/utility_widgets/scroll_pageview_notification.dart';
import 'package:datenschutz_chatbot/utility_widgets/update_progress_notification.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mailto/mailto.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:random_string/random_string.dart';
import 'package:url_launcher/url_launcher.dart';

import 'intro_screen.dart';

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
  TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: BottyColors.darkBlue, title: const Text("Einstellungen", textAlign: TextAlign.center,)),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0,0,8,16),
                        child: Image.asset("assets/img/data-white.png", width: 75, color: Colors.black,),
                      ),
                      const Text(
                        "Botty",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 48,
                          // color: Colors.white
                        ),
                      ),
                      Container(width: 25,),
                    ],
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
                  const Text("🏫 Spielst du in der Klasse?"),
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
            child: InkWell(
              borderRadius: BorderRadius.circular(30),
              onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const IntroScreen()),
                  );
                },
              child: Container(
                padding: const EdgeInsets.only(left: 20, bottom: 20, top: 10, right: 20),
                width: double.infinity,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(Icons.refresh_outlined),
                    ),
                    Text("Intro erneut starten", style: TextStyle(fontSize: 16,),)
                  ],
                ),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text("🕹️ Cheats", style: TextStyle(fontWeight: FontWeight.bold),),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 8, right: 8),
                    child: Text("Hast du einen Code für uns?"),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(children: [
                      Expanded(
                          flex: 8,
                          child: TextField(
                            controller: textEditingController,
                            decoration: const InputDecoration(
                              hintText: "Cheat-Code",// optional
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: BottyColors.darkBlue),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: BottyColors.darkBlue),
                            ),
                          ),)),
                      Expanded(
                        flex: 2,
                          child: IconButton(onPressed: submitCheat, icon: const Icon(Icons.lock_open)))
                    ],),
                  )

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
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 35),
                  ),
                  ExpandablePanel(
                      header: const Text("Status-Informationen", style: TextStyle(fontWeight: FontWeight.bold),),
                      collapsed: const Text("Debug-Prints, die uns beim Finden von Fehlern helfen können"),
                      expanded: Column(children: [
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
                    ],)),

                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
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
                      padding: EdgeInsets.all(12.0),
                      child: Icon(Icons.feedback_outlined),
                    ),
                    Text("Gib uns Feedback!", style: TextStyle(fontSize: 16),),
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
    final mailtoLink = Mailto(
      to: ['gereon.elvers@tum.de'],
      subject: 'Botty: Feedback',
    );
    await launch('$mailtoLink');
  }


  submitCheat() async {
    String input = textEditingController.text;
    if(input.contains(RegExp("Level:\\d"))||input=="Level:-1"){
      int level = -1;
      try {
        level = int.parse(input.split(":")[1]);
      } on FormatException catch (_, e){
        invalidCheatFlushbar();
        return;
      }

      if (level<5){
        // Enable classroom mode
        progress.setValue("classroomToggle", true);
        // Reset progress
        for(int i=0;i<5;i++){
          progress.setValue("started"+i.toString(), false);
          progress.setValue("messagedStarted"+i.toString(), false);
          progress.setValue("finished"+i.toString(), false);
          progress.setValue("messageFinished"+i.toString(), false);
        }
        // Progress to specified level
        for(int i=0;i<=level;i++){
          progress.setValue("started"+i.toString(), true);
          progress.setValue("messagedStarted"+i.toString(), true);
          progress.setValue("finished"+i.toString(), true);
          if(!(i==level)) progress.setValue("messageFinished"+i.toString(), true);
        }
        // Tell the PageView...
        UpdateProgressNotification().dispatch(context);
        // ... and the user about it
        await Flushbar(
          margin: const EdgeInsets.fromLTRB(15,32,15,10),
          borderRadius: BorderRadius.circular(20),
          backgroundColor: Colors.white,
          titleColor: Colors.black,
          messageColor: Colors.black,
          animationDuration: const Duration(milliseconds: 200),
          icon: Lottie.asset("assets/lottie/botty-float.json"),
          flushbarPosition: FlushbarPosition.TOP,
          title: 'Cheat aktiviert!',
          message: "Zu Level "+level.toString()+" gesprungen ⏩",
          boxShadows: const [BoxShadow(color: Colors.grey, offset: Offset(0.0, 0.2), blurRadius: 6.0)],
          duration: const Duration(milliseconds: 1500),
        ).show(context);
      } else {
        invalidCheatFlushbar();
      }
    } else {
      invalidCheatFlushbar();
    }
  }

  invalidCheatFlushbar() async {
    await Flushbar(
      margin: const EdgeInsets.fromLTRB(15,32,15,10),
      borderRadius: BorderRadius.circular(20),
      backgroundColor: Colors.white,
      titleColor: Colors.black,
      messageColor: Colors.black,
      animationDuration: const Duration(milliseconds: 200),
      icon: Lottie.asset("assets/lottie/botty-float.json"),
      flushbarPosition: FlushbarPosition.TOP,
      title: 'Leider nein!',
      message: "Der Code ist leider falsch",
      boxShadows: const [BoxShadow(color: Colors.grey, offset: Offset(0.0, 0.2), blurRadius: 6.0)],
      duration: const Duration(milliseconds: 1500),
    ).show(context);
  }

}