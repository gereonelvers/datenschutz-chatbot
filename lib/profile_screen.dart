import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// this is is the profile screen widget, currently only shows app info
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with TickerProviderStateMixin {
  @override
  void initState() {
    getInfo();
    super.initState();
  }

  String sessionID = ""; // Unique, auto-generated session ID for Rasa. Auto-generated if not present.
  String versionNumber = ""; // Current version and build number

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF799EB0),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 64, 16, 16),
        children: [
          Material(
            shape: const CircleBorder(),
            color: Colors.white,
            child: CircularPercentIndicator(
              radius: 100.0,
              lineWidth: 10.0,
              percent: 0.6,
              backgroundColor: Colors.white,
              progressColor: const Color(0xFF1C313A),
              center: Image.asset(
                "assets/img/data-white.png",
                color: Colors.black,
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 20)),
          Material(
            type: MaterialType.card,
            elevation: 5,
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.only(left: 20, bottom: 20, top: 10, right: 20),
              width: double.infinity,
              child: Column(
                children: [
                  const Text(
                    "Botty",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      // color: Colors.white
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 2, 0, 0),
                    child: Text(
                      versionNumber,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Padding(padding: EdgeInsets.fromLTRB(0, 10, 0, 10)),
          Material(
            type: MaterialType.card,
            elevation: 5,
            color: Colors.white,
            borderRadius: BorderRadius.circular(30),
            child: Container(
              padding: const EdgeInsets.only(left: 20, bottom: 20, top: 10, right: 20),
              child: Column(
                children: [
                  const Text(
                    "\"Botty - der Datenschutz-Chatbot\" ist ein Projekt des Bachelor-Praktikums \n\"IT-basiertes Lernen gestalten\" des \ni17-Lehrstuhls an der TU München.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      // color: Colors.white
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                  ),
                  Text(
                    "Rasa session-ID:\n" + sessionID,
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Get sessionID from SharedPreferences, version number from PackageInfo
  getInfo() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      sessionID = prefs.getString("session-id") ?? randomString(32);
      versionNumber = "Version: v" + packageInfo.version + "+" + packageInfo.buildNumber;
    });
    prefs.setString("session-id", sessionID);
  }
}
