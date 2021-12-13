import 'package:datenschutz_chatbot/screens/settings_screen.dart';
import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:datenschutz_chatbot/utility_widgets/progress_model.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';


/// this is is the profile screen, which shows player progress and achievements
/// TODO: Very much WIP, code is somewhat of a mess right now :)
class ProgressScreen extends StatefulWidget {
  const ProgressScreen({Key? key}) : super(key: key);

  @override
  _ProgressScreenState createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> with TickerProviderStateMixin {

  late ProgressModel progress;

  String name = "Botty";
  int currentChapter = 0;
  List<int> challengeValues = [0,0,0];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // For some reason this needs to be done in the build method instead of initState like the other pages
    // Should not significantly impact performance though, as Hive heavily caches for this exact scenario
    initProgressModel();
    return Scaffold(
      backgroundColor: BottyColors.darkBlue,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Container(
              color: BottyColors.darkBlue,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Padding(padding: EdgeInsets.only(top: 20, bottom: 40)),
                  Material(
                    elevation: 10,
                    shape: const CircleBorder(),
                    color: Colors.white,
                    child: CircularPercentIndicator(
                      radius: 100.0,
                      lineWidth: 10.0,
                      percent: ((currentChapter+1)/6),
                      backgroundColor: Colors.white,
                      progressColor: currentChapter == 5?Colors.green:Colors.grey,
                      center:
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          "assets/img/data-white.png",
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(name,
                    style: const TextStyle(color: Colors.white, fontSize: 24),),
                  ),
                  const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                  Card(
                    elevation: 10,
                    //margin: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30))),
                        //borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
                    child: Column(
                      children: [
                        const Padding(
                          padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Freischaltbare Inhalte',
                              textAlign: TextAlign.start,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: 15,
                            itemBuilder: (BuildContext context, int index) {
                              return
                              Card(
                                elevation: 5,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30))),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16, bottom: 16),
                                    child: Image.asset("assets/img/data-white.png", color: Colors.black),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Text('Dummy Card Text'),
                                        Text("Dummy Card Text"),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );

                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Challenges',
                              textAlign: TextAlign.start,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 150,
                          child: ListView(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            children:[
                                Card(
                                  elevation: 5,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(30))),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Align(
                                          alignment: Alignment.topRight,
                                            child: Icon(Icons.local_fire_department, color: BottyColors.darkBlue, size: 64,)),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.fromLTRB(8,0,8,8),
                                        child: Text("Maximale Streak"),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(8,0,8,8),
                                        child: Text(challengeValues[0].toString()),
                                      ),
                                    ],
                                  ),
                                ),
                              Card(
                                elevation: 5,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30))),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Align(
                                          alignment: Alignment.topRight,
                                          child: Icon(Icons.timer, color: BottyColors.darkBlue, size: 64,)),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(8,0,8,8),
                                      child: Text("Schnellster Run"),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(8,0,8,8),
                                      child: Text(challengeValues[1].toString() + ":00"),
                                    ),
                                  ],
                                ),
                              ),
                              Card(
                                elevation: 5,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(30))),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Align(
                                          alignment: Alignment.topRight,
                                          child: Icon(Icons.timer, color: BottyColors.darkBlue, size: 64,)),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(8,0,8,8),
                                      child: Text("Gesamte XP"),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(8,0,8,8),
                                      child: Text(challengeValues[1].toString()),
                                    ),
                                  ],
                                ),
                              ),
                            ]
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'Racing Game',
                              textAlign: TextAlign.start,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: 15,
                            itemBuilder: (BuildContext context, int index) {
                              return
                                Card(
                                  elevation: 5,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(30))),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16, bottom: 16),
                                        child: Image.asset("assets/img/data-white.png", color: Colors.black),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Text('Dummy Card Text'),
                                            Text("Dummy Card Text"),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );

                            },
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Text(
                              'RPG',
                              textAlign: TextAlign.start,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 150,
                          child: ListView.builder(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: 15,
                            itemBuilder: (BuildContext context, int index) {
                              return
                                Card(
                                  elevation: 5,
                                  shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(30))),
                                  child: Row(
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 16, bottom: 16),
                                        child: Image.asset("assets/img/data-white.png", color: Colors.black),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: const [
                                            Text('Dummy Card Text'),
                                            Text("Dummy Card Text"),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                            },
                          ),
                        ),
                        const Padding(padding: EdgeInsets.only(top: 10, bottom: 30),)
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const SettingsScreen()),
                  );
                }, icon: const Icon(Icons.settings, color: Colors.white,)),
              )),
        ],
      ),
    );
  }

  initProgressModel() async {
    progress = await ProgressModel.getProgressModel();
    setState(() {
      String n = progress.getString("username");
      if (n != "") name = n;
      currentChapter = progress.getCurrentChapter();
      challengeValues[0] = progress.getInt("challengeMaxStreak");
      challengeValues[1] = progress.getInt("challengeFastestComplete");
      challengeValues[2] = progress.getInt("challengeTotalXP");
    });
  }
}
