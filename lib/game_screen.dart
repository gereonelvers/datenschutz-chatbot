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
    currentScene = gameID;
    super.initState();
  }

  int gameID = -1;
  int currentScene = -1;
  late UnityWidgetController unityWidgetController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Stack(
        children: [
          UnityWidget(
            onUnityCreated: onUnityCreated,
            onUnityMessage: onUnityMessage,
            onUnitySceneLoaded: onUnitySceneLoaded,
            fullscreen: false,
            borderRadius: BorderRadius.zero,
            placeholder: const Center(
              child: Text("Unity loading..."),
            ),
          ),
          Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: FloatingActionButton(
                  onPressed: () {
                    changeScene();
                  },
                  child: const Icon(Icons.arrow_forward),
                ),
              ))
        ],
      )
          // Center(child: Text("Game Screen\n Game ID: " + gameID.toString())),
          ),
    );
  }

  void changeScene() {
    currentScene = ((currentScene + 1) % 4);
    unityWidgetController.postMessage("Scene Switcher 0", "Sceneswitcher", currentScene.toString());
    unityWidgetController.postMessage("Scene Switcher 1", "Sceneswitcher", currentScene.toString());
    unityWidgetController.postMessage("Scene Switcher 2", "Sceneswitcher", currentScene.toString());
    unityWidgetController.postMessage("Scene Switcher 3", "Sceneswitcher", currentScene.toString());
    unityWidgetController.postMessage("Scene Switcher 4", "Sceneswitcher", currentScene.toString());
  }

  // Communication from Unity to Flutter
  void onUnityMessage(message) {
    // TODO: Implement unity->flutter messaging. Remove print afterwards.
    print('Received message from unity: ${message.toString()}');
  }

  // Callback that connects the created controller to the unity controller
  void onUnityCreated(controller) async {
    unityWidgetController = controller;
    // This is an awful fix: Keep widget paused for .1 second to prevent freezing
    await unityWidgetController.pause();
    Future.delayed(
      const Duration(milliseconds: 100),
      () async {
        await unityWidgetController.resume();
      },
    );
    loadScene();
  }

  // This works by telling all possible Unity Scene Switchers to load the current scene
  void loadScene() async {
    print("Sending message onUnityCreated to load scene " + gameID.toString()); // TODO: Remove print once Unity scene loading works 100% (including nested scene layouts)
    // Since we can't be sure which scene is currently loaded, we just spam all Scene Switchers
    unityWidgetController.postMessage("Scene Switcher 0", "Sceneswitcher", gameID.toString());
    unityWidgetController.postMessage("Scene Switcher 1", "Sceneswitcher", gameID.toString());
    unityWidgetController.postMessage("Scene Switcher 2", "Sceneswitcher", gameID.toString());
    unityWidgetController.postMessage("Scene Switcher 3", "Sceneswitcher", gameID.toString());
    unityWidgetController.postMessage("Scene Switcher 4", "Sceneswitcher", gameID.toString());
  }

  // Leaving callback method in here for now, not currently used for anything though
  void onUnitySceneLoaded(SceneLoaded? sceneLoaded) {}

  @override
  void dispose() {
    print("dispose() called!"); // TODO: Remove print once Unity Livecycle implementation works 100%
    // unityWidgetController.unload();  // Android only?!
    // unityWidgetController.quit();    // Quits app?
    unityWidgetController.dispose();
    super.dispose();
  }
}
