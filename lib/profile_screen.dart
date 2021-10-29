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
    getData();
    super.initState();
  }

  String sessionID = ""; // Unique, auto-generated session ID for Rasa. Auto-generated if not present.

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
              children: [
                Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Colors.blue,
                      size: 80,
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        padding: const EdgeInsets.only(left: 50, bottom: 20, top: 0, right: 50),
                        height: 80,
                        width: double.infinity,
                        child: Material(
                          type: MaterialType.button,
                          borderRadius: BorderRadius.circular(30),
                          elevation: 5,
                          color: Colors.white,
                          child: const Center(
                              child: Text(
                            "ITBL Datenschutz-Chatbot",
                            style: TextStyle(
                              fontSize: 16,
                              // color: Colors.white
                            ),
                          )),
                        ),
                      ),
                    ),
                    Text(
                      "Rasa session-ID:\n" + sessionID,
                      textAlign: TextAlign.center,
                    )
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Get data from remote sources (SharedPreferences, DBs, ...)
  getData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      sessionID = prefs.getString("session-id") ?? randomString(32);
    });
    prefs.setString("session-id", sessionID);
  }
}
