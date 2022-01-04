import 'package:datenschutz_chatbot/screens/settings_screen.dart';
import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:datenschutz_chatbot/utility_widgets/progress_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:lottie/lottie.dart';
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

  // Miscellaneous
  String name = "Botty";
  int currentChapter = 0;

  // Unlockables
  List<String> unlockableNames = ["goldenBackground", "freeTextInput"];
  List<String> unlockableTitle = ["Goldener Hintergrund", "Freitext-Eingabe"];
  List<Icon> unlockableIcons = [const Icon(Icons.wallpaper), const Icon(Icons.local_fire_department)];
  List<bool> unlockablesAvailable = [false, false];
  List<bool> unlockablesActive = [false, false];

  List<int> challengeValues = [0,0,0];

  // Racing Game (TODO)
  Color carColor = Colors.white;
  int raceTime = 0;

  // RPG (TODO)

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
          Lottie.asset("assets/lottie/profile-background.json", ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
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
                    percent: ((currentChapter + 1) / 6),
                    backgroundColor: Colors.white,
                    progressColor: currentChapter == 5 ? Colors.amber : Colors.green,
                    center: Padding(
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
                  child: Text(
                    name,
                    style: const TextStyle(color: Colors.white, fontSize: 24,
                    shadows: [Shadow(offset: Offset(0.0, 0.5),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),)]),
                  ),
                ),
                const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
                Card(
                  elevation: 10,
                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                  margin: EdgeInsets.zero,
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
                            itemCount: unlockableNames.length,
                            itemBuilder: (BuildContext context, int index) {
                              return UnlockableCard(
                                  unlocked: unlockablesAvailable[index],
                                  active: unlockablesActive[index],
                                  title: unlockableTitle[index],
                                  icon: unlockableIcons[index],
                                  update: () => toggleUnlockable(index)
                              );
                            },
                        )
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
                        height: 160,
                        child: ListView(
                            physics: const BouncingScrollPhysics(),
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal, children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                            child: Card(
                              elevation: 5,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                              child: InkWell(
                                splashColor: Colors.blue.withAlpha(30),
                                borderRadius: BorderRadius.circular(30),
                                onTap: () {},
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Align(
                                          alignment: Alignment.topRight,
                                          child: Icon(
                                            Icons.local_fire_department,
                                            color: BottyColors.darkBlue,
                                            size: 64,
                                          )),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                                      child: Text("Maximale Streak"),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                      child: Text(challengeValues[0].toString()),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                            child: Card(
                              elevation: 5,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                              child: InkWell(
                                splashColor: Colors.blue.withAlpha(30),
                                borderRadius: BorderRadius.circular(30),
                                onTap: () {},
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Align(
                                          alignment: Alignment.topRight,
                                          child: Icon(
                                            Icons.timer,
                                            color: BottyColors.darkBlue,
                                            size: 64,
                                          )),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                                      child: Text("Schnellster Run"),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                      child: Text(Duration(seconds: challengeValues[1]).toString().split(".").first.padLeft(8, "0")),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                            child: Card(
                              elevation: 5,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                              child: InkWell(
                                splashColor: Colors.blue.withAlpha(30),
                                borderRadius: BorderRadius.circular(30),
                                onTap: () {},
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Align(
                                          alignment: Alignment.topRight,
                                          child: Icon(
                                            Icons.celebration,
                                            color: BottyColors.darkBlue,
                                            size: 64,
                                          )),
                                    ),
                                    const Padding(
                                      padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                                      child: Text("Gesamte XP"),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                      child: Text(challengeValues[1].toString()),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ]),
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
                        child: ListView(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                              child: Card(
                                elevation: 5,
                                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                                child: InkWell(
                                  splashColor: Colors.blue.withAlpha(30),
                                  borderRadius: BorderRadius.circular(30),
                                  onTap: () {},
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Align(
                                            alignment: Alignment.topRight,
                                            child: Icon(
                                              Icons.timer,
                                              color: BottyColors.darkBlue,
                                              size: 64,
                                            )),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                                        child: Text("Schnellster Run"),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                        child: Text(Duration(seconds: raceTime).toString().split(".").first.padLeft(8, "0")),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Card(
                              elevation: 5,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                              color: carColor,
                              child: InkWell(
                                splashColor: Colors.blue.withAlpha(30),
                                borderRadius: BorderRadius.circular(30),
                                onTap: pickCarColor,
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Icon(Icons.color_lens, size: 48, color: ThemeData.estimateBrightnessForColor(carColor) == Brightness.dark?Colors.white:Colors.black,)
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                                      child: Text('Fahrzeug-Farbe wählen', style: TextStyle(color: ThemeData.estimateBrightnessForColor(carColor) == Brightness.dark?Colors.white:Colors.black,)),
                                    ),
                                  ],
                                ),
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
                            return Card(
                              elevation: 5,
                              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
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
                        padding: EdgeInsets.only(top: 10, bottom: 30),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8,24,8,8),
                child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    },
                    icon: const Icon(
                      Icons.settings,
                      color: Colors.white,
                    )),
              )),
        ],
      ),
    );
  }

  toggleUnlockable(int index){
    unlockablesActive[index] = !unlockablesActive[index];
    progress.setValue(unlockableNames[index]+"Active", unlockablesActive[index]);
  }

  changeColor(Color color) {
    progress.setValue("carColor", color.value);
    setState(() => carColor = color);
  }

  pickCarColor(){
    // raise the [showDialog] widget
    showDialog(
      context: context,
      builder: (BuildContext context) { return AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(30))),
        title: const Text('Wähle eine Farbe!'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: carColor,
            onColorChanged: changeColor,
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: const Text('OK', style: TextStyle(color: BottyColors.darkBlue),),
            onPressed: () {
              //setState(() => carColor = carColor);
              Navigator.of(context).pop();
            },
          ),
        ],
      );},);
  }

  // TODO: This feels really ugly
  initProgressModel() async {
    progress = await ProgressModel.getProgressModel();
    setState(() {
      String n = progress.getString("username");
      if (n != "") name = n;

      for (int i = 0; i<unlockableNames.length;i++) {
        unlockablesAvailable[i] = progress.getBool(unlockableNames[i]+"Available");
        unlockablesActive[i] = progress.getBool(unlockableNames[i]+"Active");
      }

      currentChapter = progress.getCurrentChapter();
      challengeValues[0] = progress.getInt("challengeMaxStreak");
      challengeValues[1] = progress.getInt("challengeFastestComplete");
      challengeValues[2] = progress.getInt("challengeTotalXP");

      //print("Color: #"+progress.getInt("carColor").toRadixString(16));

      carColor = progress.getInt("carColor")==0?Colors.white:Color(progress.getInt("carColor"));
      raceTime = progress.getInt("racingTime");
    });
  }

}

class UnlockableCard extends StatelessWidget {
  const UnlockableCard({Key? key, required this.unlocked, required this.active, required this.title, required this.icon, required this.update }) : super(key: key);

  final bool unlocked;
  final bool active;
  final String title;
  final Icon icon;
  final VoidCallback update;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4,2,4,8),
      child: Card(
        elevation: 5,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
        color: active?Colors.amber:Colors.white,
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          borderRadius: BorderRadius.circular(30),
          onTap: update,
          child: Row(
            children: [
              Padding(
                  padding: const EdgeInsets.only(top: 16, bottom: 16, left: 16, right: 16),
                  child: icon
                  //Image.asset("assets/img/data-white.png", color: Colors.black),
                  ),
              Padding(
                padding: const EdgeInsets.fromLTRB(0, 0, 12, 0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(title),
                    //Text("Freigeschaltet | Aktiv"),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
