import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:datenschutz_chatbot/screens/intro_screen.dart';
import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:datenschutz_chatbot/utility_widgets/chat_chip.dart';
import 'package:datenschutz_chatbot/utility_widgets/chat_contact_bar.dart';
import 'package:datenschutz_chatbot/utility_widgets/chat_message.dart';
import 'package:datenschutz_chatbot/utility_widgets/message_list_empty_view.dart';
import 'package:datenschutz_chatbot/utility_widgets/progress_model.dart';
import 'package:datenschutz_chatbot/utility_widgets/scroll_pageview_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:random_string/random_string.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lifecycle/lifecycle.dart';

/// This is the chat screen widget that displays the main chat with Botty. Messages controlled by Rasa back end + conditionally through state management
class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin, WidgetsBindingObserver, LifecycleAware, LifecycleMixin {
  List<ChatMessage> messages = []; // List of all chat messages
  final TextEditingController textEditingController = TextEditingController(); // Controller managing the text input field
  final String chatRequestUrl = "botty-chatbot.de"; // Base URL chatbot requests are made to.
  String sessionID = ""; // Unique, auto-generated session ID for Rasa. Auto-generated on first launch.
  bool freeInputEnabled = false; // Is the user allowed to input free text or are there still more quests to complete first?
  late ProgressModel progress; // This class holds a hashmap of progress "checkpoints"
  List<String> chipStrings = ["Wer bist du?","Weiter","Hilfe","DSGVO", "/clear", "/reset"];

  @override
  initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    print("Rebuild ChatScreen");
    return Scaffold(
      body: Material(
        elevation: 5,
        type: MaterialType.card,
        color: BottyColors.blue,
        child: Stack(
          children: <Widget>[
            messages.isEmpty
                ? const MessageListEmptyView()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 115),
                    itemCount: messages.length,
                    reverse: true,
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return messages[index];
                    },
                  ),
            const Align(
              alignment: Alignment.topCenter,
              child: ChatContactBar(),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.only(left: 0, bottom: 10, top: 0, right: 0),
                height: 115,
                width: double.infinity,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: chipStrings.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              child: ChatChip(chipStrings[index]),
                              onTap: () => sendMessageChip(chipStrings[index]),
                            );
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                      child: Material(
                        type: MaterialType.button,
                        borderRadius: BorderRadius.circular(30),
                        elevation: 5,
                        color: BottyColors.darkBlue,
                        child: InkWell(
                          splashColor: Colors.blue.withAlpha(30),
                          onTap: () {
                            if (!freeInputEnabled) sendMessage();
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(15, 5, 5, 5),
                                  child: TextField(
                                    onSubmitted: (String message) => sendMessage(),
                                    controller: textEditingController,
                                    textInputAction: TextInputAction.send,
                                    cursorColor: Colors.white,
                                    style: const TextStyle(color: Colors.white),
                                    enabled: freeInputEnabled,
                                    textAlign: freeInputEnabled ? TextAlign.start : TextAlign.center,
                                    decoration: InputDecoration(contentPadding: EdgeInsets.zero, hintText: freeInputEnabled ? "Nachricht" : "Zur Kapitelübersicht 🗺️", hintStyle: const TextStyle(color: Colors.white), border: InputBorder.none),
                                  ),
                                ),
                              ),
                              if (freeInputEnabled)
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(5, 5, 15, 5),
                                  child: GestureDetector(
                                    onTap: () => sendMessage(),
                                    child: const Icon(
                                      Icons.send,
                                      color: Colors.white,
                                      size: 25,
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
            ),
          ],
        ),
      ),
    );
  }

  sendMessage() {
    if (freeInputEnabled) {
      setState(() {
        String message = textEditingController.text.trim();
        if (message.isEmpty) {
          // Commands!
          if (message == "/clear") {
            setState(() => messages.clear());
            textEditingController.clear();
            return;
          }
          if (message == "/reset") {
            setState(() => progress.reset());
            textEditingController.clear();
            return;
          }
          // New messages are appended to front to make storing&displaying large amounts of messages economical
          messages.insert(0, ChatMessage(textEditingController.text, SenderType.user));
          messages.insert(0, const ChatMessage("...", SenderType.bot));
          getResponse(message);
        }
        textEditingController.clear();
      });
    } else {
      ScrollPageViewNotification(0).dispatch(context);
    }
  }

  sendMessageChip(String message) {
    setState(() {
      // New messages are appended to front to make storing&displaying large amounts of messages economical
      if (message == "/clear") {
        setState(() => messages.clear());
        textEditingController.clear();
        return;
      }
      if (message == "/reset") {
        setState(() => progress.reset());
        textEditingController.clear();
        return;
      }
      messages.insert(0, ChatMessage(message, SenderType.user));
      messages.insert(0, const ChatMessage("...", SenderType.bot));
      getResponse(message);
    });
  }

  // This is the method actually sending the message to the rasa instance and fetching a response
  getResponse(String request) async {
    try {
      final Response response = await http.post(Uri.https(chatRequestUrl, "/webhooks/rest/webhook"), body: jsonEncode(<String, String>{'sender': sessionID, 'message': request})).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        bool firstMessage = true;
        // TODO: This is a mess lmao -> better json decoding (incl. image support)
        List<dynamic> responseItems = jsonDecode(response.body);
        for (var element in responseItems) {
          var map = Map<String, dynamic>.from(element);
          if (map.containsKey('text')) {
            insertMessageRandom(ChatMessage(map['text'], SenderType.bot));
            // Remove '...' after first message is added
            // This needs to be done here instead of above so artificial delay works correctly
            setState(() {
              if (firstMessage) {
                firstMessage = false;
                messages.removeAt(0);
              }
            });
          }
        }
      } else {
        // FIXME: better error handling here
        messages.removeAt(0);
        messages.insert(0, const ChatMessage("Tut mir leid, mein Server hat gerade leider Probleme :(", SenderType.bot));
        messages.insert(0, ChatMessage("Falls du einen Admin sehen solltest, kannst du ihm das hier ausrichten:\nStatus Code:" + response.statusCode.toString() + ": " + response.reasonPhrase.toString(), SenderType.bot));
      }
    } on TimeoutException catch (_) {
      messages.removeAt(0);
      messages.insert(0, const ChatMessage("Tut mir leid, ich kann meinen Server gerade leider nicht erreichen :(", SenderType.bot));
    } on SocketException catch (_) {
      messages.removeAt(0);
      messages.insert(0, const ChatMessage("Tut mir leid, ich kann meinen Server gerade leider nicht erreichen :(", SenderType.bot));
    }
  }

  // Save data to remote sources (SharedPreferences, DBs, ...)
  saveData() async {
    // Saving sessionID to SP
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("session-id", sessionID);
    // Saving messages to Hive
    var box = await Hive.openBox("messageBox");
    box.put("messages", messages);
  }

  // Get data from remote sources (SharedPreferences, DBs, ...)
  getData() async {
    // Doing this through SharedPreferences to avoid having to init Hive on other screens
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Check if intro screen needs to get launched
    if (prefs.getBool("isFirstLaunch") ?? true) {
      prefs.setBool("isFirstLaunch", false);
      //Future.microtask(() => Navigator.push(context, MaterialPageRoute(builder: (context) => const IntroScreen()));
      Navigator.push(context, MaterialPageRoute(builder: (context) => const IntroScreen()));
    }
    setState(() {
      sessionID = prefs.getString("session-id") ?? randomString(32);
    });
    prefs.setString("session-id", sessionID);
    await Hive.initFlutter(); // FIXME: This call is made more often than it needs to be. Does that matter?
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ChatMessageAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(SenderTypeAdapter());
    var box = await Hive.openBox('messageBox');
    var m = box.get("messages");
    setState(() {
      if (m != null) messages = m.cast<ChatMessage>();
      // If, for some reason, there is a "..." placeholder message stuck in the list, remove it here
      if (messages.isNotEmpty && messages.first.message == "..." && messages.first.type == SenderType.bot) messages.removeAt(0);
    });
    await setProgressState();
  }

  // This feels really stupid, but idk where else all this content should go ¯\_(ツ)_/¯
  // Reminder:
  // - The chapters are: 0 - Start Survey, 1 - Challenges/Duolingo, 2 - Racing Game, 3 - Naninovel RPG, 4 - End Survey
  // - The checkpoints per chapter are started, messagedStarted, finished, messagedFinished
  // Since all chapters are walked through chronologically, we can walk backwards until we find the first started chapter
  // TODO: Move this to a different file to increase legibility, change Chip content based on progress (prompts about chapter content), custom messages for starting but not finishing a quest (messageStartedn)
  setProgressState() async {
    progress = await ProgressModel.getProgressModel();

    // Check if player started chapter 4
    if (progress.getValue("started4")) {
      if (progress.getValue("finished4")) {
        // Player finished last chapter, unlock free input
        setState(() {
          freeInputEnabled = true;
        });
        if (progress.getValue("messagedFinished4")){
          // Player finished last chapter and was already messaged about it
          return;
        } else {
          insertMessageFixed(const ChatMessage("Glückwunsch, du hast das Spiel durchgespielt", SenderType.bot), 1000);
          progress.setValue("messagedFinished4", true);
        }
      }
      return;
    }

    // Check if player started chapter 3
    if (progress.getValue("started3")) {
      if (progress.getValue("finished3")) {
        // Player finished chapter 3
        if (progress.getValue("messagedFinished3")){
          // Player finished chapter 3 and was already told about it
          return;
        } else {
          insertMessageFixed(const ChatMessage("Gute Arbeit in Kapitel 3, spiel doch Kapitel 4", SenderType.bot), 1000);
          progress.setValue("messagedFinished3", true);
        }
      }
      return;
    }

    // Check if player started chapter 2
    if (progress.getValue("started2")) {
      if (progress.getValue("finished2")) {
        // Player finished chapter 2
        if (progress.getValue("messagedFinished2")){
          // Player finished chapter 2 and was already told about it
          return;
        } else {
          insertMessageFixed(const ChatMessage("Gute Arbeit in Kapitel 2, spiel doch Kapitel 3", SenderType.bot), 1000);
          progress.setValue("messagedFinished2", true);
        }
      }
      return;
    }

    // Check if player started chapter 1
    if (progress.getValue("started1")) {
      if (progress.getValue("finished1")) {
        // Player finished chapter 1
        if (progress.getValue("messagedFinished1")){
          // Player finished chapter 1 and was already told about it
          return;
        } else {
          insertMessageFixed(const ChatMessage("Gute Arbeit in Kapitel 1, spiel doch Kapitel 2", SenderType.bot), 1000);
          progress.setValue("messagedFinished1", true);
        }
      }
      return;
    }

    // Check if player started chapter 0
    if (progress.getValue("started0")) {
      if (progress.getValue("finished0")) {
        // Player finished chapter 0
        if (progress.getValue("messagedFinished0")){
          // Player finished chapter 0 and was already told about it
          return;
        } else {
          insertMessageFixed(const ChatMessage("Gute Arbeit in Kapitel 0, spiel doch Kapitel 1", SenderType.bot), 1000);
          progress.setValue("messagedFinished0", true);
        }
      }
      return;
    }

    // Check if player finished the intro
    if (progress.getValue("finishedIntro")) {
      if (!progress.getValue("messagedIntro")) {
          insertMessageFixed(const ChatMessage("Dies ist der Intro-Text, willkommen im Spiel :)", SenderType.bot), 1000);
          progress.setValue("messagedIntro", true);
      }
    }
  }

  // Inserts a message with a random delay (to make response more realistic)
  insertMessageRandom(ChatMessage message) {
    Future.delayed(Duration(milliseconds: 200 + Random().nextInt(1000 - 200)), () {
      setState(() {
        messages.insert(0, message);
      });
    });
  }

  // Inserts a message with a fixed delay (for realistic scripted interactions)
  insertMessageFixed(ChatMessage message, int delayInMs) {
    Future.delayed(Duration(milliseconds: delayInMs), () {
      setState(() {
        messages.insert(0, message);
      });
    });
  }

  // If the widget is destroyed, dispose of controllers to prevente memory leaks
  @override
  dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  // Save data if the widget becomes inactive or invisible (e.g. when the user exits the app)
  @override
  onLifecycleEvent(LifecycleEvent event) {
    if (event == LifecycleEvent.inactive || event == LifecycleEvent.invisible) saveData();
  }

}
