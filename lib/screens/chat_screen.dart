import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:datenschutz_chatbot/utility_widgets/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:random_string/random_string.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lifecycle/lifecycle.dart';

/// This is the chat screen widget that displays the main chat windows with the rasa bot
class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin, WidgetsBindingObserver, LifecycleAware, LifecycleMixin {
  List<ChatMessage> messages = [
    // TODO: Remove placeholders entirely once state management / message insertion is implemented
    // const ChatMessage("Ansonsten kannst du nach links wischen um dir die Karte anzuschauen. Rechts gibt es ein paar weitere Infos.\nViel Spaß!", SenderType.bot),
    // const ChatMessage("Versuch doch einfach, mir eine Nachricht zu schreiben!", SenderType.bot),
    // const ChatMessage("Hi, ich bin Botty — der Datenschutz-Chatbot. Aktuell kann ich leider noch nicht so viel, aber das wird sich bald ändern :)", SenderType.bot)
  ]; // List of all chat messages
  final TextEditingController textEditingController = TextEditingController(); // Controller managing the text input field
  final String chatRequestUrl = "botty-chatbot.de"; // Base URL chatbot requests are made to.
  String sessionID = ""; // Unique, auto-generated session ID for Rasa. Auto-generated on first launch.

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
        elevation: 5,
        type: MaterialType.card,
        color: BottyColors.blue,
        child: Stack(
          children: <Widget>[
            messages.isEmpty
                ? const Center(child: Text("No message placeholder"))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 90),
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
                padding: const EdgeInsets.only(left: 10, bottom: 20, top: 10, right: 10),
                height: 90,
                width: double.infinity,
                child: Material(
                  type: MaterialType.button,
                  borderRadius: BorderRadius.circular(30),
                  elevation: 5,
                  color: BottyColors.darkBlue,
                  child: InkWell(
                    splashColor: Colors.blue.withAlpha(30),
                    onTap: () {},
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
                              decoration: const InputDecoration(contentPadding: EdgeInsets.zero, hintText: "Nachricht", hintStyle: TextStyle(color: Colors.white), border: InputBorder.none),
                            ),
                          ),
                        ),
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
            ),
          ],
        ),
      ),
    );
  }

  sendMessage() {
    setState(() {
      String message = textEditingController.text;
      if (message.trim() != "") {
        // New messages are appended to front to make storing&displaying large amounts of messages economical
        messages.insert(0, ChatMessage(textEditingController.text, SenderType.user));
        messages.insert(0, const ChatMessage("...", SenderType.bot));
        getResponse(message);
      }
      textEditingController.clear();
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
      if (messages.first.message == "..." && messages.first.type == SenderType.bot) messages.removeAt(0);
    });
  }

  // Inserts a message with a random delay (to make response more realistic)
  void insertMessageRandom(ChatMessage message) {
    Future.delayed(Duration(milliseconds: 200 + Random().nextInt(1000 - 200)), () {
      setState(() {
        messages.insert(0, message);
      });
    });
  }

  // Inserts a message with a fixed delay (for realistic scripted interactions)
  void insertMessageFixed(ChatMessage message, int delayInMs) {
    Future.delayed(Duration(milliseconds: delayInMs), () {
      setState(() {
        messages.insert(0, message);
      });
    });
  }

  // If the widget is destroyed, dispose of controllers to prevente memory leaks
  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  // Save data if the widget becomes inactive or invisible (e.g. when the user exits the app)
  @override
  void onLifecycleEvent(LifecycleEvent event) {
    if (event == LifecycleEvent.inactive || event == LifecycleEvent.invisible) saveData();
  }
}

class ChatContactBar extends StatelessWidget {
  const ChatContactBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 50, bottom: 0, top: 40, right: 50),
      height: 100,
      width: double.infinity,
      child: Material(
        type: MaterialType.button,
        borderRadius: BorderRadius.circular(30),
        elevation: 5,
        color: BottyColors.greyWhite,
        child: InkWell(
          splashColor: Colors.blue.withAlpha(30),
          onTap: () {},
          borderRadius: BorderRadius.circular(30),
          child: Row(
            children: [
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(36, 4, 16, 4),
                  child: Image.asset(
                    "assets/img/data-white.png",
                    color: Colors.black,
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    "Botty",
                    style: TextStyle(fontSize: 16),
                  ),
                  Text(
                    "⬤ online", // FIXME: The dot is broken on web. Fixable with custom font additions? Maybe add actual status indicator?
                    style: TextStyle(color: Colors.green),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
