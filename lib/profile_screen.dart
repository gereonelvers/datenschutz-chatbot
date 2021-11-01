import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// this is is the profile screen widget, currently only shows app info
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    getSessionID();
    super.initState();
  }

  String sessionID = ""; // Unique, auto-generated session ID for Rasa. Auto-generated if not present.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Material(
        elevation: 5,
        type: MaterialType.card,
        color: const Color(0xFF799EB0),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 128, 16, 128),
              child: Material(
                elevation: 5,
                type: MaterialType.card,
                color: const Color(0xfff5f5f5),
                child: Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF799EB0),
                      size: 80,
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        padding: const EdgeInsets.only(left: 20, bottom: 20, top: 0, right: 20),
                        height: 160,
                        width: double.infinity,
                        child: const Center(
                            child: Text(
                          "\"Botty - der Datenschutz-Chatbot\" ist ein Projekt des Bachelor-Praktikums \n\"IT-basiertes Lernen gestalten\" des \ni17-Lehrstuhls an der TU München.",
                          style: TextStyle(
                            fontSize: 16,
                            // color: Colors.white
                          ),
                        )),
                      ),
                    ),
                    Text(
                      "Rasa session-ID:\n" + sessionID,
                      textAlign: TextAlign.center,
                    )
                  ],
                )),
              ),
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
                  color: const Color(0xfff5f5f5),
                  child: const Center(
                      child: Text(
                    "Profil/Informationen",
                    style: TextStyle(
                      fontSize: 16,
                      // color: Colors.white
                    ),
                  )),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Get sessionID from SharedPreferences
  getSessionID() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      sessionID = prefs.getString("session-id") ?? randomString(32);
    });
    prefs.setString("session-id", sessionID);
  }
}
