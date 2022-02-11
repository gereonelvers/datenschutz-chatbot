import 'package:datenschutz_chatbot/screens/settings_screen.dart';
import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:datenschutz_chatbot/utility_widgets/progress_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_material_pickers/flutter_material_pickers.dart';
import 'package:lottie/lottie.dart';
import 'package:percent_indicator/percent_indicator.dart';

/// this is is the profile screen, which shows player progress and achievements
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
  List<String> unlockableNames = ["goldenBackground"];
  List<String> unlockableTitle = ["Goldener Hintergrund"];
  List<Icon> unlockableIcons = [const Icon(Icons.wallpaper)];
  List<bool> unlockablesAvailable = [false];
  List<bool> unlockablesActive = [false];

  List<int> challengeValues = [0,0,0];

  // Racing Game
  Color raceCarColor = Colors.white;
  int raceTime = 0;
  List<String> raceCarHatTypes = ["Kein Hut", "Partyhut", "Zylinder", "Zauberhut"];
  int raceCarHat = 0;
  List<String> carSpeedTypes = ["Langsam", "Normal", "Schnell","Turbo"];
  int raceCarSpeed = 0;

  // RPG (TODO)
  bool rpgStarted = false;
  int rpgStarCount = 0;
  int rpgLessonCount = 0;
  bool rpgCameraUnlocked = false;

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
      backgroundColor: BottyColors.greyWhite,
      body: Stack(
        children: [
          Lottie.asset("assets/lottie/profile-background.json", height: double.infinity, fit: BoxFit.fitHeight),
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
                      padding: const EdgeInsets.all(16.0),
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
                      Visibility(
                        visible: currentChapter == 5,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Align(
                            alignment: Alignment.topLeft,
                            child: Row(
                              children: [
                                const Text(
                                  'Belohnungen',
                                  textAlign: TextAlign.start,
                                  style: TextStyle(fontSize: 18),
                                ),
                                IconButton(icon: const Icon(Icons.info), onPressed: () {
                                  showDialog(context: context, builder: (BuildContext context){
                                    return AlertDialog(
                                        title: const Text('Belohnungen 🎉'),
                                        shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(30))),
                                        content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: const [
                                              Text("Du hast das Spiel durchgespielt und dadurch einige Belohnungen freigeschaltet!"),
                                            ]),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                            Navigator.of(context).pop();
                                            },
                                            child: const Text('Okay', style: TextStyle(color: BottyColors.darkBlue)),
                                            ),
                                        ]
                                    );
                                  });
                                },)
                              ],
                            ),
                          ),
                        ),
                      ),
                      Visibility(
                        visible: currentChapter == 5,
                        child: SizedBox(
                          height: 150,
                          child: Align(
                            alignment: Alignment.centerLeft,
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
                            ),
                          )
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Grundlagen mit Tante Meta',
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 160,
                        child: Align(
                          alignment: Alignment.centerLeft,
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
                                        child: Text(challengeValues[2].toString()),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Fahrt zur Schule',
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 150,
                        child: Align(
                          alignment: Alignment.centerLeft,
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
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                                child: Card(
                                  elevation: 5,
                                  shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                                  child: InkWell(
                                    splashColor: Colors.blue.withAlpha(30),
                                    borderRadius: BorderRadius.circular(30),
                                    onTap: pickCarHat,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Align(
                                              alignment: Alignment.topRight,
                                              child: Icon(
                                                Icons.compare,
                                                color: BottyColors.darkBlue,
                                                size: 64,
                                              )),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                                          child: Text("Hut wählen"),
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
                                    onTap: pickCarColor,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Align(
                                              alignment: Alignment.topRight,
                                              child: Icon(
                                                Icons.color_lens,
                                                color: BottyColors.darkBlue,
                                                size: 64,
                                              )),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                                          child: Text("Auto-Farbe wählen"),
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
                                    onTap: pickCarSpeed,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Align(
                                              alignment: Alignment.topRight,
                                              child: Icon(
                                                Icons.speed,
                                                color: BottyColors.darkBlue,
                                                size: 64,
                                              )),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                                          child: Text("Geschwindigkeit wählen"),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),


                            ]
                          ),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.fromLTRB(24, 24, 24, 16),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            'Erster Schultag',
                            textAlign: TextAlign.start,
                            style: TextStyle(fontSize: 18),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 100,
                        child: Align(
                          alignment: Alignment.centerLeft,
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
                                    onTap: (){},
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Align(
                                              alignment: Alignment.topRight,
                                              child: Icon(
                                                Icons.school,
                                                color: BottyColors.darkBlue,
                                                size: 64,
                                              )),
                                        ),
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                          const Padding(
                                            padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                                            child: Text("Schule besucht?"),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                                            child: Text(rpgStarted?"Ja 👨‍🎓":"Nein 😔"),
                                          ),
                                        ],)
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                      ]
                          ),
                        ),),
                      // SizedBox(
                      //   height: 150,
                      //   child: ListView(
                      //     physics: const BouncingScrollPhysics(),
                      //     shrinkWrap: true,
                      //     scrollDirection: Axis.horizontal,
                      //     children: [
                      //       Padding(
                      //         padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      //         child: Card(
                      //           elevation: 5,
                      //           shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                      //           child: InkWell(
                      //             splashColor: Colors.blue.withAlpha(30),
                      //             borderRadius: BorderRadius.circular(30),
                      //             onTap: (){},
                      //             child: Column(
                      //               mainAxisAlignment: MainAxisAlignment.center,
                      //               children: [
                      //                 const Padding(
                      //                   padding: EdgeInsets.all(8.0),
                      //                   child: Align(
                      //                       alignment: Alignment.topRight,
                      //                       child: Icon(
                      //                         Icons.star,
                      //                         color: BottyColors.darkBlue,
                      //                         size: 64,
                      //                       )),
                      //                 ),
                      //                 const Padding(
                      //                   padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                      //                   child: Text("Verdiente Sterne"),
                      //                 ),
                      //                 Padding(
                      //                   padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      //                   child: Text(rpgStarCount.toString()),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //       Padding(
                      //         padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      //         child: Card(
                      //           elevation: 5,
                      //           shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                      //           child: InkWell(
                      //             splashColor: Colors.blue.withAlpha(30),
                      //             borderRadius: BorderRadius.circular(30),
                      //             onTap: (){},
                      //             child: Column(
                      //               mainAxisAlignment: MainAxisAlignment.center,
                      //               children: [
                      //                 const Padding(
                      //                   padding: EdgeInsets.all(8.0),
                      //                   child: Align(
                      //                       alignment: Alignment.topRight,
                      //                       child: Icon(
                      //                         Icons.today,
                      //                         color: BottyColors.darkBlue,
                      //                         size: 64,
                      //                       )),
                      //                 ),
                      //                 const Padding(
                      //                   padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                      //                   child: Text("Absolvierte Stunden"),
                      //                 ),
                      //                 Padding(
                      //                   padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      //                   child: Text(rpgLessonCount.toString()),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //       Padding(
                      //         padding: const EdgeInsets.fromLTRB(0, 0, 0, 8),
                      //         child: Card(
                      //           elevation: 5,
                      //           shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(30))),
                      //           child: InkWell(
                      //             splashColor: Colors.blue.withAlpha(30),
                      //             borderRadius: BorderRadius.circular(30),
                      //             onTap: (){},
                      //             child: Column(
                      //               mainAxisAlignment: MainAxisAlignment.center,
                      //               children: [
                      //                 const Padding(
                      //                   padding: EdgeInsets.all(8.0),
                      //                   child: Align(
                      //                       alignment: Alignment.topRight,
                      //                       child: Icon(
                      //                         Icons.video_camera_front_outlined,
                      //                         color: BottyColors.darkBlue,
                      //                         size: 64,
                      //                       )),
                      //                 ),
                      //                 const Padding(
                      //                   padding: EdgeInsets.fromLTRB(8, 0, 8, 8),
                      //                   child: Text("Kamera freigeschaltet?"),
                      //                 ),
                      //                 Padding(
                      //                   padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
                      //                   child: Text(rpgCameraUnlocked?"Ja 😄":"Nein 😔"),
                      //                 ),
                      //               ],
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //
                      //     ],
                      //   ),
                      // ),
                      const Padding(
                        padding: EdgeInsets.only(top: 10, bottom: 10),
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
                padding: const EdgeInsets.fromLTRB(8,48,8,8),
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
            pickerColor: raceCarColor,
            onColorChanged: (color){
              progress.setValue("carColor", color.value);
              setState(() => raceCarColor = color);
            },
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

  // This isn't particularly pretty
  pickCarSpeed(){
    int speed = progress.getInt("carSpeed");
    showMaterialScrollPicker(
      context: context,
      title: 'Geschwindkeit wählen',
      items: carSpeedTypes,
      headerColor: BottyColors.darkBlue,
      backgroundColor: BottyColors.greyWhite,
      selectedItem: carSpeedTypes[speed],
      onChanged: (String value) {
        int speed = (carSpeedTypes.indexOf(value));
        progress.setValue("carSpeed", speed);
        setState(() => raceCarSpeed = speed);
      },
    );
  }

  // This isn't particularly pretty
  pickCarHat(){
    int carHat = progress.getInt("carHat");
    showMaterialScrollPicker(
      context: context,
      title: 'Hut wählen',
      items: raceCarHatTypes,
      headerColor: BottyColors.darkBlue,
      backgroundColor: BottyColors.greyWhite,
      selectedItem: raceCarHatTypes[carHat],
      onChanged: (String value) {
        int hat = (raceCarHatTypes.indexOf(value));
        progress.setValue("carHat", hat);
        setState(() => raceCarHat = hat);
      },
    );
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) { return AlertDialog(
    //     shape: const RoundedRectangleBorder(
    //         borderRadius: BorderRadius.all(Radius.circular(30))),
    //     title: const Text('Wähle einen Hut!'),
    //     content: SizedBox(
    //       height: 300,
    //       child: ListView.builder(
    //           physics: const BouncingScrollPhysics(),
    //           itemCount: carHatTypes.length,
    //           itemBuilder: (BuildContext c, int index) {
    //         return Card(
    //           elevation: 5,
    //             color: index==currentHat?BottyColors.darkBlue:Colors.white,
    //             child: InkWell(
    //               onTap: () {
    //                 changeCarHat(index);
    //               },
    //               child: Padding(
    //                 padding: const EdgeInsets.all(16.0),
    //                 child: Row(
    //                   children: [
    //                     Icon(Icons.local_fire_department, color: index==currentHat?Colors.white:Colors.black,),
    //                     Padding(
    //                       padding: const EdgeInsets.all(8.0),
    //                       child: Text(carHatTypes[index], style: TextStyle(color: index==currentHat?Colors.white:Colors.black),),
    //                     ),
    //                   ],
    //                 ),
    //               ),
    //             ));
    //       }),
    //     ),
    //     actions: <Widget>[
    //       TextButton(
    //         child: const Text('OK', style: TextStyle(color: BottyColors.darkBlue),),
    //         onPressed: () {
    //           //setState(() => carColor = carColor);
    //           Navigator.of(context).pop();
    //         },
    //       ),
    //     ],
    //   );},);
  }

  changeCarHat(int index) {
    progress.setValue("carHat", index);
    setState(() => raceCarHat = index);
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

      raceCarColor = progress.getInt("carColor")==0?Colors.white:Color(progress.getInt("carColor"));
      raceCarHat = progress.getInt("carHat");
      raceTime = progress.getInt("raceTime");

      rpgStarCount = progress.getInt("starCount");
      rpgLessonCount = progress.getInt("lessonCount");
      rpgCameraUnlocked = progress.getBool("cameraUnlocked");
      rpgStarted = progress.getBool("rpgStarted");
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
