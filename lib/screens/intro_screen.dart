import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:datenschutz_chatbot/utility_widgets/progress_model.dart';
import 'package:flutter/material.dart';

/// This is the screen that introduces the user to the app on first launch
class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: BottyColors.greyWhite,
      child: Column(
        children: [
          Expanded(
            child: PageView(
              scrollDirection: Axis.horizontal,
              controller: controller,
              children: const <Widget>[IntroWelcomeScreen(), IntroConsentScreen(), IntroFinishScreen()],
            ),
          ),
          Row(
            children: [
              Expanded(
                  child: TextButton(
                onPressed: backward,
                child: const Text("Zurück", style: TextStyle(color: Colors.black)),
              )),
              Expanded(
                  child: TextButton(
                onPressed: forward,
                child: const Text("Weiter", style: TextStyle(color: Colors.black)),
              )),
            ],
          )
        ],
      ),
    );
  }

  backward() {
    if (controller.page != 0) {
      controller.animateToPage(controller.page!.toInt() - 1, duration: const Duration(milliseconds: 200), curve: Curves.ease);
    }
  }

  forward() {
    if (controller.page != 2) {
      if(controller.page == 1) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if(IntroConsentScreen.DATA_CONSENT) {
          controller.animateToPage(controller.page!.toInt() + 1,
              duration: const Duration(milliseconds: 200), curve: Curves.ease);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Bitte akzeptiere den Datenschutz-Consent"),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        controller.animateToPage(controller.page!.toInt() + 1,
            duration: const Duration(milliseconds: 200), curve: Curves.ease);
      }
    } else {
      exitIntro();
    }
  }

  exitIntro() async {
    ProgressModel progress = await ProgressModel.getProgressModel();
    progress.setValue("finishedIntro", true);
    Navigator.of(context).pop();
  }

}




// First Screen
class IntroWelcomeScreen extends StatelessWidget {
  const IntroWelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      alignment: Alignment.center,
      color: BottyColors.greyWhite,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 32, 8, 64),
            child: Text(
              "Willkommen!",
              style: TextStyle(color: BottyColors.darkBlue, fontSize: 32),
            ),
          ),
          ClipRRect(
            child: Container(
              child: Image.asset(
                "assets/img/data-white.png",
                height: 180,
                width: 180,
                color: BottyColors.darkBlue,
              ),
              color: Colors.white,
            ),
            borderRadius: BorderRadius.circular(180.0),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 32, 8, 0),
            child: Text(
              "Hi, ich bin Botty!",
              style: TextStyle(color: BottyColors.darkBlue, fontSize: 22),
            ),
          ),
          Text(
            "Lass uns gemeinsam\nDatenschutz lernen!",
            style: TextStyle(color: BottyColors.darkBlue, fontSize: 16),
          ),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(8, 32, 8, 0),
          //   child: Text(
          //     "Logos bald hier (TUM, DigiConsult,...)",
          //     style: TextStyle(color: BottyColors.darkBlue, fontSize: 20),
          //   ),
          // )
        ],
      ),
    ));
  }
}

// Second Screen
class IntroConsentScreen extends StatefulWidget {
  const IntroConsentScreen({Key? key}) : super(key: key);
  static bool DATA_CONSENT = false;

  @override
  _IntroConsentScreenState createState() => _IntroConsentScreenState();
}

class _IntroConsentScreenState extends State<IntroConsentScreen> {

  String name = "Anonym";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      alignment: Alignment.center,
      color: BottyColors.greyWhite,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 32, 4, 64),
            child: Text(
              "Erstmal der Papierkram...",
              style: TextStyle(color: BottyColors.darkBlue, fontSize: 24),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
            child: TextFormField(
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                labelText: "Wie heißt du?",
              ),
              onChanged: updateName,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 32, 8, 0),
            child:
            Text(
              "Gespeicherter Name: "+name.toString(),
              style: TextStyle(color: BottyColors.darkBlue, fontSize: 20),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 32, 8, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState((){
                      IntroConsentScreen.DATA_CONSENT = !IntroConsentScreen.DATA_CONSENT;
                      if(IntroConsentScreen.DATA_CONSENT) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      }
                    });
                  },
                  child: Text(
                    "Datenschutz-Consent bald hier",
                    style: TextStyle(color: BottyColors.darkBlue, fontSize: 20),
                  ),
                ), const Spacer(),
                Align(
                  alignment: Alignment.topRight,
                  child: Checkbox(
                    checkColor: Colors.white,
                    activeColor: Colors.green,
                    value: IntroConsentScreen.DATA_CONSENT,
                    onChanged: (bool? value) {
                      setState(() {
                        IntroConsentScreen.DATA_CONSENT = value!;
                        if(IntroConsentScreen.DATA_CONSENT) {
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 32, 8, 0),
            child: Text(
              "Classroom toggle bald hier",
              style: TextStyle(color: BottyColors.darkBlue, fontSize: 20),
            ),
          )
        ],
      ),
    ));
  }

  void updateName(String text) {
    setState((){
      name = text;
    });
  }
}

// Third Screen
class IntroFinishScreen extends StatelessWidget {
  const IntroFinishScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      alignment: Alignment.center,
      color: BottyColors.greyWhite,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 32, 4, 64),
            child: Text(
              "Und los geht's!",
              style: TextStyle(color: BottyColors.darkBlue, fontSize: 24),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 32, 8, 0),
            child: Text(
              "Kontext/Finale Infos bald hier",
              style: TextStyle(color: BottyColors.darkBlue, fontSize: 20),
            ),
          ),
        ],
      ),
    ));
  }
}
