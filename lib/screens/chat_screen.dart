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
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
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
  List<String> defaultChipStrings = ["Wer bist du?", "Weiter", "Hilfe", "Definitionen"];
  Color backgroundColor = BottyColors.blue;
  String username = "Spieler";

  @override
  initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
        elevation: 5,
        type: MaterialType.card,
        color: backgroundColor,
        child: Stack(
          children: <Widget>[
            messages.isEmpty
                ? const MessageListEmptyView()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 135),
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
                padding: const EdgeInsets.only(left: 0, bottom: 30, top: 0, right: 0),
                height: 135,
                width: double.infinity,
                child: Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          scrollDirection: Axis.horizontal,
                          itemCount: (messages.isNotEmpty&&messages.first.suggestions.isNotEmpty)?messages.first.suggestions.length:defaultChipStrings.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              child: ChatChip((messages.isNotEmpty&&messages.first.suggestions.isNotEmpty)?messages.first.suggestions[index]:defaultChipStrings[index]),
                              onTap: () => sendMessageChip((messages.isNotEmpty&&messages.first.suggestions.isNotEmpty)?messages.first.suggestions[index]:defaultChipStrings[index]),
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
        if (message.isNotEmpty) {
          // New messages are appended to front to make storing&displaying large amounts of messages economical
          messages.insert(0, ChatMessage(textEditingController.text, SenderType.user, []));
          messages.insert(0, const ChatMessage("...", SenderType.bot, []));
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
      messages.insert(0, ChatMessage(message, SenderType.user, const []));
      messages.insert(0, const ChatMessage("...", SenderType.bot, []));
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
            if (map.containsKey('buttons')) {
              List<dynamic> buttons = map["buttons"];
              List<String> buttonStrings = [];
              for (var element in buttons) {
                buttonStrings.add(element["title"]);
              }
              insertMessageRandom(ChatMessage(map['text'], SenderType.bot, buttonStrings));
            } else {
              insertMessageRandom(ChatMessage(map['text'], SenderType.bot, const []));
            }
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
        messages.insert(0, const ChatMessage("Tut mir leid, mein Server hat gerade leider Probleme :(", SenderType.bot, []));
        messages.insert(0, ChatMessage("Falls du einen Admin sehen solltest, kannst du ihm das hier ausrichten:\nStatus Code:" + response.statusCode.toString() + ": " + response.reasonPhrase.toString(), SenderType.bot, const []));
      }
    } on TimeoutException catch (_) {
      messages.removeAt(0);
      messages.insert(0, const ChatMessage("Tut mir leid, ich kann meinen Server gerade leider nicht erreichen :(", SenderType.bot, []));
    } on SocketException catch (_) {
      messages.removeAt(0);
      messages.insert(0, const ChatMessage("Tut mir leid, ich kann meinen Server gerade leider nicht erreichen :(", SenderType.bot, []));
    }
  }

  // Save data to remote sources (SharedPreferences, DBs, ...)
  saveData() async {
    // Saving sessionID
    progress.setValue("sessionID", sessionID);

    // Saving messages to Hive
    var box = await Hive.openBox("messageBox");
    box.put("messages", messages);


  }

  // Get data from remote sources (SharedPreferences, DBs, ...)
  getData() async {
    await setProgressState();
    String s = progress.getString("sessionID");
    if (s=="") {
      s = randomString(32);
      progress.setValue("sessionID", sessionID);
    }
    setState(() {
      sessionID = s;
    });

    // Check if intro screen needs to get launched
    // TODO: This sometimes launches IntroScreen twice. Why?
    if (!progress.getBool("finishedIntro")) {
      await Navigator.push(context, MaterialPageRoute(builder: (context) => const IntroScreen()));
      progress.setValue("finishedIntro", true);
      setProgressState();
    }
    if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(ChatMessageAdapter());
    if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(SenderTypeAdapter());
    var box = await Hive.openBox('messageBox');
    var m = box.get("messages");
    setState(() {
      if (m != null) messages = m.cast<ChatMessage>();
      // If, for some reason, there is a "..." placeholder message stuck in the list, remove it here
      if (messages.isNotEmpty && messages.first.message == "..." && messages.first.type == SenderType.bot) messages.removeAt(0);
    });
  }

  // This feels really stupid, but idk where else all this content should go ¯\_(ツ)_/¯
  // Reminder:
  // - The chapters are: 0 - Start Survey, 1 - Challenges/Duolingo, 2 - Racing Game, 3 - Naninovel RPG, 4 - End Survey
  // - The checkpoints per chapter are started, messagedStarted, finished, messagedFinished
  // Since all chapters are walked through chronologically, we can walk backwards until we find the first started chapter
  // TODO: Move this to a different file to increase legibility, change Chip content based on progress (prompts about chapter content), custom messages for starting but not finishing a quest (messageStartedn)
  setProgressState() async {
    progress = await ProgressModel.getProgressModel();

    setState(() {
      backgroundColor = progress.getBool("goldenBackgroundActive") ? Colors.amber : BottyColors.blue;
      freeInputEnabled = !progress.getBool("classroomToggle");
      username = progress.getString("username")==""?"User":progress.getString("username");
    });

    if (progress.getBool("classroomToggle")) {
      // Check if player started chapter 4
      if (progress.getBool("started4")) {
        if (progress.getBool("finished4")) {
          // Player finished last chapter, unlock free input
          setState(() {
            freeInputEnabled = true;
          });
          if (progress.getBool("messagedFinished4")) {
            // Player finished last chapter and was already messaged about it
            return;
          } else {
            insertMessageFixed(const ChatMessage("Jetzt", SenderType.padding, []), const Duration(milliseconds: 10));
            insertMessageFixed(const ChatMessage("Woah, du hast es echt geschafft!", SenderType.bot, []), const Duration(milliseconds: 100));
            insertMessageFixed(const ChatMessage("Du hast alle Kapitel durchgespielt und bist jetzt ein echter Datenschutz-Experte!", SenderType.bot, []), const Duration(milliseconds: 1000));
            insertMessageFixed(const ChatMessage("Ich übrigens auch 😄", SenderType.bot, []), const Duration(milliseconds: 2000));
            insertMessageFixed(const ChatMessage("Solltest du doch noch mal eine Rückfrage haben, kannst du mich jederzeit über das Textfeld unten erreichen!", SenderType.bot, []), const Duration(milliseconds: 3000));
            Future.delayed(const Duration(milliseconds: 3100), (){
              progress.setValue("messagedFinished4", true);
              saveData();
            });
          }
        }
        return;
      }

      // Check if player started chapter 3
      if (progress.getBool("started3")) {
        if (progress.getBool("finished3")) {
          // Player finished chapter 3
          if (progress.getBool("messagedFinished3")) {
            // Player finished chapter 3 and was already told about it
            return;
          } else {
            insertMessageFixed(const ChatMessage("16:36", SenderType.padding, []), const Duration(milliseconds: 10));
            insertMessageFixed(const ChatMessage("Großartige Arbeit! Wir haben den ersten Schultag gemeistert!", SenderType.bot, []), const Duration(milliseconds: 100));
            insertMessageFixed(const ChatMessage("Meine Eltern haben noch eine zweite kleine Umfrage... Könntest du die vielleicht auch noch ausfüllen?", SenderType.bot, []), const Duration(milliseconds: 1000));
            insertMessageFixed(const ChatMessage("Wähle dafür einfach auf der Karte das Testzentrum ganz unten aus. Es kann sein, dass du dafür nach unten wischen musst!", SenderType.bot, []), const Duration(milliseconds: 1500));
            insertMessageFixed(const ChatMessage("Damit ich weiß, wie ich in Zukunft noch besser werden kann 😅", SenderType.bot, []), const Duration(milliseconds: 2000));
            Future.delayed(const Duration(milliseconds: 2100), (){
              progress.setValue("messagedFinished3", true);
              saveData();
            });
          }
        }
        return;
      }

      // Check if player started chapter 2
      if (progress.getBool("started2")) {
        if (progress.getBool("finished2")) {
          // Player finished chapter 2
          if (progress.getBool("messagedFinished2")) {
            // Player finished chapter 2 and was already told about it
            return;
          } else {
            insertMessageFixed(ChatMessage(DateFormat('HH:mm').format(DateTime.now()), SenderType.padding, const []), const Duration(milliseconds: 10));
            insertMessageFixed(const ChatMessage("Was für ein Trip!", SenderType.bot, []), const Duration(milliseconds: 100));
            insertMessageFixed(const ChatMessage("Und jetzt noch einmal durchatmen und dann rein ins Abenteuer!", SenderType.bot, []), const Duration(milliseconds: 1000));
            insertMessageFixed(const ChatMessage("Starte den Schultag über die Kapitelübersicht, sobald du bereit bist.", SenderType.bot, []), const Duration(milliseconds: 2000));
            insertMessageFixed(const ChatMessage("Übrigens: Wenn du die Strecke erneut fahren möchstest, kannst du in deinem Profil andere Geschwindigkeiten, Auto-Farben und Hüte wählen 🤠", SenderType.bot, []), const Duration(milliseconds: 2500));
            insertMessageFixed(const ChatMessage("Wische dafür einfach nach rechts! ", SenderType.bot, []), const Duration(milliseconds: 2600));
            Future.delayed(const Duration(milliseconds: 2100), (){
              progress.setValue("messagedFinished2", true);
              saveData();
            });
          }
        }
        return;
      }

      // Check if player started chapter 1
      if (progress.getBool("started1")) {
        if (progress.getBool("finished1")) {
          // Player finished chapter 1
          if (progress.getBool("messagedFinished1")) {
            // Player finished chapter 1 and was already told about it
            return;
          } else {
            insertMessageFixed(const ChatMessage("08:55", SenderType.padding, []), const Duration(milliseconds: 10));
            insertMessageFixed(const ChatMessage("Guten Morgen!☀️", SenderType.bot, []), const Duration(milliseconds: 100));
            insertMessageFixed(const ChatMessage("Oh nein, es ist schon kurz vor 9 Uhr! 😲 Dabei wollte ich doch noch meine Notizen von gestern anschauen...", SenderType.bot, []), const Duration(milliseconds: 1000));
            insertMessageFixed(const ChatMessage("Das muss ich dann wohl unterwegs machen 🤷", SenderType.bot, []), const Duration(milliseconds: 4000));
            insertMessageFixed(const ChatMessage("Starte die Fahrt über die Kapitelübersicht", SenderType.bot, []), const Duration(milliseconds: 4500));
            Future.delayed(const Duration(milliseconds: 4600), (){
              progress.setValue("messagedFinished1", true);
              saveData();
            });
          }
        }
        return;
      }

      // Check if player started chapter 0
      if (progress.getBool("started0")) {
        if (progress.getBool("finished0")) {
          // Player finished chapter 0
          if (progress.getBool("messagedFinished0")) {
            // Player finished chapter 0 and was already told about it
            return;
          } else {
            insertMessageFixed(ChatMessage(DateFormat('HH:mm').format(DateTime.now()), SenderType.padding, const []), const Duration(milliseconds: 10));
            insertMessageFixed(const ChatMessage("Danke! Weißt du, ich bin besonders aufgeregt, weil ich morgen den ersten Tag an meiner neuen Schule habe. Wir sind nämlich gerade erst nach Smartphoningen gezogen.", SenderType.bot, []), const Duration(milliseconds: 100));
            insertMessageFixed(const ChatMessage("In der neuen Schule soll ich Datenschutz sogar als Profilfach belegen - wie spannend 🤩", SenderType.bot, []), const Duration(milliseconds: 1000));
            insertMessageFixed(const ChatMessage("Deshalb kommt gleich auch noch Tante Meta vorbei. Die arbeitet nämlich als Datenschutz-Chatbot und hat mir versprochen, mich auf morgen vorzubereiten.", SenderType.bot, []), const Duration(milliseconds: 2000));
            insertMessageFixed(ChatMessage((DateTime.now().hour+1).toString() + ":" + DateTime.now().minute.toString(), SenderType.padding, const []), const Duration(milliseconds: 4000));
            insertMessageFixed(const ChatMessage("Ah, da kommt sie ja auch schon. Starte in der Kapitelübersicht das Treffen!", SenderType.bot, []), const Duration(milliseconds: 4100));
            Future.delayed(const Duration(milliseconds: 4200), (){
              progress.setValue("messagedFinished0", true);
              saveData();
            });
          }
        }
        return;
      }
    }

    // Check if player finished the intro
    if (progress.getBool("finishedIntro")) {
      if (!progress.getBool("messagedIntro")) {
        insertMessageFixed(ChatMessage(DateFormat('HH:mm').format(DateTime.now()), SenderType.padding, const []), const Duration(milliseconds: 10));
        insertMessageFixed(ChatMessage("Hi "+username+", ich bin Botty. Ich freue mich, dich kennenzulernen!", SenderType.bot, const []), const Duration(milliseconds: 100));

        if (progress.getBool("classroomToggle")) insertMessageFixed(const ChatMessage("Heute werden wir uns zusammen mit dem Thema Datenschutz auseinandersetzen. Ich freue mich schon 😊", SenderType.bot, []), const Duration(milliseconds: 1000));
        if (progress.getBool("classroomToggle")) insertMessageFixed(const ChatMessage("Bevor wir loslegen können, haben meine Eltern mich darum gebeten, dass du bitte noch eine kleine Umfrage ausfüllst. Keine Sorge, es ist auch kein Test 😊", SenderType.bot, []), const Duration(milliseconds: 2000));
        if (progress.getBool("classroomToggle")) insertMessageFixed(const ChatMessage("Wische einfach zur Karte links oder drücke auf den Knopf unten und wähle auf der Karte das Testzentrum aus! Ich habe es mit einem roten Marker versehen!", SenderType.bot, []), const Duration(milliseconds: 3000));
        if (progress.getBool("classroomToggle")) insertMessageFixed(const ChatMessage("Neben der Karte links und dem Chat mit mir in der Mitte kannst du übrigens auch nach rechts wischen um dir dein Profil anzuschauen!", SenderType.bot, []), const Duration(milliseconds: 4000));

        if (!progress.getBool("classroomToggle")) insertMessageFixed(const ChatMessage("Aktuell befinde ich mich noch in der Entwicklung. Wenn du mich also von meiner besten Seite sehen möchtest, solltest du in den Einstellungen den Klassenraum-Modus einschalten!", SenderType.bot, []), const Duration(milliseconds: 1000));
        if (!progress.getBool("classroomToggle")) insertMessageFixed(const ChatMessage("Ansonsten kann ich dir keine Tipps geben. So würdest du nie erfahren, dass du die Spielkarte links und für dein Profil rechts von mir finden kannst 😊!", SenderType.bot, []), const Duration(milliseconds: 2000));
        Future.delayed(const Duration(milliseconds: 2100), (){
          progress.setValue("messagedIntro", true);
          saveData();
        });
      }
    }
  }

  // TODO: The insertions should be done as e.g. CancelableOperation with a global queue so that outstanding messages can be canceled/skipped on dispose
  // Inserts a message with a random delay (to make response more realistic)
  insertMessageRandom(ChatMessage message) {
    Future.delayed(Duration(milliseconds: 200 + Random().nextInt(1000 - 200)), () {
      setState(() {
        messages.insert(0, message);
      });
    });
  }

  // Inserts a message with a fixed delay (for realistic scripted interactions)
  insertMessageFixed(ChatMessage message, Duration delay) {
    Future.delayed(delay, () {
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
