import 'dart:async';

import 'package:datenschutz_chatbot/utility_widgets/progress_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class GameScreen extends StatefulWidget {
  final int gameID;

  const GameScreen(this.gameID, {Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  @override
  initState() {
    gameID = widget.gameID;
    initProgressModel();
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      // Telling Unity to switch car color to preset value
      int carColorId = progressModel.getInt("carColor");
      String carColor = carColorId==0?"#ffffff":"#"+progressModel.getInt("carColor").toRadixString(16).substring(2);
      unityWidgetController.postMessage("AchievementCarColor", "AchievementChangeColor", carColor); // TODO: This currently only works if unity player is already loaded
      int carSpeedId = progressModel.getInt("carSpeed");
      String carSpeed;
      switch(carSpeedId){
        case 1:
          carSpeed = "medium";
          break;
        case 2:
          carSpeed = "fast";
          break;
        case 3:
          carSpeed = "reallyFast";
          break;
        case 0:
        default:
          carSpeed = "slow";
          break;
      }
      unityWidgetController.postMessage("AchievementMaxSpeed", "AchievementMaxSpeed", carSpeed);

      int carHatId = progressModel.getInt("carHat");
      String carHat;
      switch(carHatId){
        case 1:
          carHat = "PartyHat";
          break;
        case 2:
          carHat = "TopHat";
          break;
        case 3:
          carHat = "WizardHat";
          break;
        case 0:
        default:
          carHat = "NoHat";
          break;
      }
      unityWidgetController.postMessage("AchievementHats", "AchievementHats", carHat);

    });
    super.initState();
  }

  int gameID = -1;
  late UnityWidgetController unityWidgetController;
  late ProgressModel progressModel;
  late Timer timer;
  int duration = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child:
          Stack(
        children: [
        UnityWidget(
          onUnityCreated: onUnityCreated,
          onUnityMessage: onUnityMessage,
          onUnitySceneLoaded: onUnitySceneLoaded,
          fullscreen: true, // Setting this to false causes a bunch of issues in release builds
          borderRadius: BorderRadius.zero,
          placeholder: const Center(
            child: Text("Unity loading..."),
          ),
        ),
            Align(
                alignment: Alignment.topLeft,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(8,32,0,0),
                  child: IconButton(onPressed: () => Navigator.of(context).pop(), icon: Icon(Icons.arrow_back)),
                ))
          ],
        )
      ),
    );
  }

  // Communication from Unity to Flutter
  onUnityMessage(message) {
    print('Received message from unity: $message'); // Remove print once no longer required
    if(message.contains("raceTime")){
      int d = double.parse((message.split(":")[1].toString().replaceAll(",", "."))).round();
      duration = d;
    } else if (message == "return") {
      if (duration>progressModel.getInt("raceTime")){
        progressModel.setValue("raceTime", duration);
      }
      Navigator.pop(context, true);
    } else if (message.contains("starCount")) {
      int starCount = int.parse(message.split(":")[1]);
      progressModel.setValue("starCount", starCount);
    } else if (message.contains("lesson")) {
      int lesson = int.parse(message.split(":")[1]);
      progressModel.setValue("lessonCount", lesson);
    } else if (message.contains("camera")) {
      progressModel.setValue("cameraUnlocked", true);
    }


  }

  // Callback that connects the created controller to the unity controller
  onUnityCreated(controller) async {
    unityWidgetController = controller;
    // This is an awful fix: Keep widget paused for .1 second to prevent freezing
    await unityWidgetController.pause();
    Future.delayed(
      const Duration(milliseconds: 100),
          () async {
        await unityWidgetController.resume();
      },
    );
    loadScene(gameID);
  }

  // This works by telling the Scene Switchers item in the currently Unity Scene to load the correct scene
  loadScene(int id) async {
    print("Sending message telling Unity to load scene with id" + id.toString()); // TODO: Remove print once Unity scene loading works 100% (including nested scene layouts)
    if (id==0) {
      unityWidgetController.postMessage("Scene Switcher", "Sceneswitcher", "IntroMenu");
    } else {
      //unityWidgetController.postMessage("Scene Switcher", "Sceneswitcher", "GameScene4");
      unityWidgetController.postMessage("Scene Switcher", "Sceneswitcher", "GameScene4");
    }
  }

  // Leaving callback method in here for now, not currently used for anything though
  onUnitySceneLoaded(SceneLoaded? sceneLoaded) {
    print("Loaded scene: " + sceneLoaded!.name.toString());
  }

  @override
  dispose() {
    print("dispose() called!"); // TODO: Remove print once Unity Livecycle implementation works 100%
    // unityWidgetController.unload();  // Android only?!
    // unityWidgetController.quit();    // Quits app?
    // unityWidgetController.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
    timer.cancel();
    super.dispose();
  }

  initProgressModel() async {
    progressModel = await ProgressModel.getProgressModel();
  }

}