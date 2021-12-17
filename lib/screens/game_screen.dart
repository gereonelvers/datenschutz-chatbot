import 'package:flutter/material.dart';
import 'package:flutter_unity_widget/flutter_unity_widget.dart';

class GameScreen extends StatefulWidget {
  final int gameID;

  const GameScreen(this.gameID, {Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    gameID = widget.gameID;
    super.initState();
  }

  int gameID = -1;
  late UnityWidgetController unityWidgetController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text("Zurück")),
              )),
          UnityWidget(
            onUnityCreated: onUnityCreated,
            onUnityMessage: onUnityMessage,
            onUnitySceneLoaded: onUnitySceneLoaded,
            fullscreen: true, // Setting this to false causes a bunch of issues in release builds
            borderRadius: BorderRadius.zero,
            placeholder: const Center(
              child: Text("Unity loading..."),
            ),
          )
        ],
      )),
    );
  }

  // Communication from Unity to Flutter
  onUnityMessage(message) {
    // TODO: Implement unity->flutter messaging. Remove print afterwards.
    print('Received message from unity: ${message.toString()}');
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
    if (id==3) {
      //unityWidgetController.postMessage("Scene Switcher", "Sceneswitcher", "IntroMenu");
      unityWidgetController.postMessage("Scene Switcher", "Sceneswitcher", "MainScene");
    } else {
      unityWidgetController.postMessage("Scene Switcher", "Sceneswitcher", "GameScene4");
    }


    //unityWidgetController.postMessage("Scene Switcher", "Sceneswitcher", id.toString());
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
    super.dispose();
  }
}
