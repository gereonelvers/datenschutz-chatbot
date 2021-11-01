import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:datenschutz_chatbot/chat_message.dart';
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
    const ChatMessage("Ansonsten kannst du nach links wischen um dir deine Minispiele anzuschauen, oder nach rechts wischen um dein Profil anzusehen.\nViel Spaß!", SenderType.bot),
    const ChatMessage("Versuch doch einfach, mit der Tastatur mit mir zu reden", SenderType.bot),
    const ChatMessage("Hi, ich bin Botty - der Datenschutz-Chatbot. Aktuell kann ich leider noch nicht so viel, aber das wird sich bald ändern :)", SenderType.bot)
  ]; // List of all chat messages
  final TextEditingController textEditingController = TextEditingController(); // Controller managing the text input field
  final String chatRequestUrl = "202.61.246.43"; // Base URL chatbot requests are made to. TODO: Get an URL set up for this ASAP
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
        color: const Color(0xff455a64),
        child: Stack(
          children: <Widget>[
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(0, 0, 0, 110),
              itemCount: messages.length,
              reverse: true,
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                return messages[index];
              },
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                padding: const EdgeInsets.only(left: 50, bottom: 0, top: 20, right: 50),
                height: 80,
                width: double.infinity,
                child: Material(
                  type: MaterialType.button,
                  borderRadius: BorderRadius.circular(30),
                  elevation: 5,
                  color: const Color(0xfff5f5f5),
                  child: Row(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(4, 4, 0, 4),
                          child: RawMaterialButton(onPressed: () {}, fillColor: const Color(0xff1c313a), shape: const CircleBorder(), elevation: 0, child: Image.asset("assets/img/botty-weiß.png")),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Botty Robotson",
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            "⬤ online",
                            style: TextStyle(
                              color: Colors.green,
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                padding: const EdgeInsets.only(left: 10, bottom: 40, top: 10, right: 10),
                height: 110,
                width: double.infinity,
                child: Material(
                  type: MaterialType.button,
                  borderRadius: BorderRadius.circular(30),
                  elevation: 5,
                  color: const Color(0xff1c313a),
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
          ],
        ),
      ),
    );
  }

  sendMessage() {
    //saveData();
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
      final Response response = await http.post(Uri.http(chatRequestUrl, "/webhooks/rest/webhook"), body: jsonEncode(<String, String>{'sender': sessionID, 'message': request})).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        setState(() {
          messages.removeAt(0);
          // TODO: This is a mess lmao -> better json decoding (incl. image support)
          List<dynamic> responseItems = jsonDecode(response.body);
          for (var element in responseItems) {
            var map = Map<String, dynamic>.from(element);
            if (map.containsKey('text')) {
              messages.insert(0, ChatMessage(map['text'], SenderType.bot));
            }
          }
        });
      } else {
        // TODO: Toast/ better error handling here
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
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("session-id", sessionID);

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

    await Hive.initFlutter();
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

  // If the widget is destroyed, dispose of controllers to prevente memory leaks
  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  void onLifecycleEvent(LifecycleEvent event) {
    // Save data if the widget becomes inactive or invisible (e.g. when the user exits the app)
    if (event == LifecycleEvent.inactive || event == LifecycleEvent.invisible) saveData();
  }
}
