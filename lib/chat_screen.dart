import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:datenschutz_chatbot/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:random_string/random_string.dart';

/// This is the chat screen widget that displays the main chat windows with the rasa bot
class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Material(
            elevation: 5,
            type: MaterialType.card,
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
                    height: 50,
                    width: double.infinity,
                    child: Material(
                      type: MaterialType.button,
                      borderRadius: BorderRadius.circular(30),
                      elevation: 5,
                      color: Colors.white,
                      child: const Center(
                          child: Text(
                        "Botty (Chatbot)",
                        style: TextStyle(
                          fontSize: 16,
                          // color: Colors.white
                        ),
                      )),
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
                      color: Colors.blue,
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
                                decoration: const InputDecoration(
                                    contentPadding: EdgeInsets.zero,
                                    hintText: "Nachricht",
                                    hintStyle: TextStyle(color: Colors.white),
                                    border: InputBorder.none),
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
      final Response response = await http
          .post(Uri.http(chatRequestUrl, "/webhooks/rest/webhook"), body: jsonEncode(<String, String>{'sender': sessionID, 'message': request}))
          .timeout(const Duration(seconds: 6));
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
        // If getting Auth-Token wasn't successful, retry
        // TODO: Toast/ better error handling here
        messages.removeAt(0);
        messages.insert(0, const ChatMessage("Tut mir leid, mein Server hat gerade leider Probleme :(", SenderType.bot));
        messages.insert(0,
            ChatMessage(
                "Falls du einen Admin sehen solltest, kannst du ihm das hier ausrichten:\nStatus Code:" +
                    response.statusCode.toString() + ": " + response.reasonPhrase.toString(),
                SenderType.bot));
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
    // TODO: Implement db storage for messages
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("session-id", sessionID);
  }

  // Get data from remote sources (SharedPreferences, DBs, ...)
  getData() async {
    // TODO: Implement db storage for messages
    SharedPreferences prefs = await SharedPreferences.getInstance();
    sessionID = prefs.getString("session-id") ?? randomString(32);

    // TODO: Remove this once regular saving works
    prefs.setString("session-id", sessionID);
  }

  // If the widget is destroyed, dispose of controllers and save data
  @override
  void dispose() {
    textEditingController.dispose();
    saveData();
    super.dispose();
  }

// TODO: fix lifecycle management
/*  // Watch application lifecycle so data can be saved on pause
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.paused:
        saveData();
        break;
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.detached:
        break;
    }
  }*/

}
