import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:datenschutz_chatbot/utility_widgets/progress_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'package:simple_ripple_animation/simple_ripple_animation.dart';

/// This is the screen that introduces the user to the app on first launch
class IntroScreen extends StatefulWidget {
  const IntroScreen({Key? key}) : super(key: key);

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  final PageController controller = PageController(initialPage: 0);

  @override
  initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Container(
        color: BottyColors.greyWhite,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                scrollDirection: Axis.horizontal,
                controller: controller,
                physics: const NeverScrollableScrollPhysics(),
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
      ),
    );
  }

  backward() {
    setState(() {
      if (controller.page != 0) {
        controller.animateToPage(controller.page!.toInt() - 1, duration: const Duration(milliseconds: 200), curve: Curves.ease);
      }
    });
  }

  forward() {
    setState(() {
      if (controller.page == 1) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        if (!IntroConsentScreen.changedName) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Bitte gib deinen Namen an"),
            backgroundColor: Colors.red,
          ));
          return;
        }
        if (!IntroConsentScreen.dataConsent) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Bitte akzeptiere den Datenschutz-Consent"),
            backgroundColor: Colors.red,
          ));
          return;
        }
        controller.animateToPage(controller.page!.toInt() + 1, duration: const Duration(milliseconds: 200), curve: Curves.ease);
      } else if (controller.page == 2) {
        exitIntro();
      } else {
        controller.animateToPage(controller.page!.toInt() + 1, duration: const Duration(milliseconds: 200), curve: Curves.ease);
      }
    });
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
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 0, 8, 32),
            child: Text(
              "Willkommen!",
              style: TextStyle(color: BottyColors.darkBlue, fontSize: 32),
            ),
          ),
          RippleAnimation(
            repeat: true,
            color: BottyColors.darkBlue,
            minRadius: 70,
            duration: const Duration(seconds: 3),
            delay: const Duration(seconds: 3),
            ripplesCount: 2,
            child: Material(
              elevation: 20,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(45))),
              child: InkWell(
                onTap: () {},
                borderRadius: const BorderRadius.all(Radius.circular(45)),
                child: Image.asset(
                  "assets/img/data-white.png",
                  height: 180,
                  width: 180,
                  color: BottyColors.darkBlue,
                ),
              ),
              color: Colors.white,
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 48, 8, 0),
            child: Text(
              "Hi, ich bin Botty!",
              style: TextStyle(color: BottyColors.darkBlue, fontSize: 22),
            ),
          ),
          const Text(
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
  static bool dataConsent = false;
  static bool changedName = false;

  @override
  _IntroConsentScreenState createState() => _IntroConsentScreenState();
}

class _IntroConsentScreenState extends State<IntroConsentScreen> {
  @override
  initState() {
    initProgressModel();
    super.initState();
  }

  String name = "Name";
  late ProgressModel progress;
  bool classroomToggle = true; // defaults to true (since we dont want the user to accidentally fail to select)
  int _index = 0; // index for stepper

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
          const Padding(
            padding: EdgeInsets.fromLTRB(8, 16, 8, 8),
            child: Text(
              "📝 Erstmal der Papierkram...",
              style: TextStyle(color: BottyColors.darkBlue, fontSize: 24),
            ),
          ),
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Stepper(
              physics: const ClampingScrollPhysics(),
              controlsBuilder: (BuildContext context, ControlsDetails details) {
                return Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Visibility(
                    visible: !(_index == 2),
                    child: Row(
                      children: [
                        Visibility(
                          visible: !(_index == 0),
                          child: TextButton(
                            onPressed: details.onStepCancel,
                            child: const Text(
                              'Zurück',
                              style: TextStyle(color: BottyColors.darkBlue),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                BottyColors.blue,
                              ),
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15.0),
                              ))),
                          child: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text(
                              'Weiter',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
              currentStep: _index,
              onStepCancel: () {
                if (_index > 0) {
                  setState(() {
                    _index -= 1;
                  });
                }
              },
              onStepContinue: () {
                if (_index <= 1) {
                  setState(() {
                    _index += 1;
                  });
                }
              },
              onStepTapped: (int index) {
                setState(() {
                  _index = index;
                });
              },
              steps: [
                Step(
                  title: const Text("💻 Name", style: TextStyle(fontSize: 18)),
                  content: Column(
                    children: [
                      const Text(
                        "Wie dürfen wir dich nennen? 🤔",
                        textAlign: TextAlign.start,
                        style: TextStyle(fontSize: 16),
                      ),
                      const Padding(padding: EdgeInsets.only(bottom: 18)),
                      TextField(
                        cursorColor: BottyColors.darkBlue,
                        decoration: InputDecoration(
                            hoverColor: BottyColors.darkBlue,
                            hintText: name,
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: const BorderSide(color: BottyColors.darkBlue),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: const BorderSide(color: BottyColors.darkBlue),
                            ),
                            labelText: "Name",
                            labelStyle: const TextStyle(color: BottyColors.darkBlue)),
                        onChanged: updateName,
                      ),
                    ],
                  ),
                  //state: StepState.complete
                ),
                Step(
                    title: const Text("📜 Datenschutzerklärung", style: TextStyle(fontSize: 18)),
                    content: Column(
                      children: [
                        const SizedBox(
                            height: 250,
                            child: SingleChildScrollView(
                                physics: BouncingScrollPhysics(),
                                child: Text(
                                    "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."))),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
                          child: Row(children: [
                            Expanded(
                              flex: 1,
                              child: Checkbox(
                                value: IntroConsentScreen.dataConsent,
                                onChanged: (bool? value) {
                                  setState(() {
                                    IntroConsentScreen.dataConsent = !IntroConsentScreen.dataConsent;
                                  });
                                },
                                activeColor: BottyColors.darkBlue,
                              ),
                            ),
                            Flexible(
                              flex: 4,
                              child: Wrap(
                                children: const [
                                  Text(
                                    "Ich habe die Datenschutzerklärung gelesen und stimme ihr zu.",
                                  ),
                                ],
                              ),
                            )
                          ]),
                        )
                      ],
                    )),
                Step(
                  title: const Text("🎮 Spielmodus", style: TextStyle(fontSize: 18)),
                  content: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                classroomToggle = !classroomToggle;
                                progress.setValue("classroomToggle", classroomToggle);
                              });
                            },
                            child: const Text(
                              "Spielst du in der Klasse?",
                              style: TextStyle(color: BottyColors.darkBlue, fontSize: 16),
                            ),
                          ),
                          const Spacer(),
                          Align(
                              alignment: Alignment.topRight,
                              child: Switch(
                                activeColor: BottyColors.blue,
                                onChanged: (bool value) {
                                  setState(() {
                                    classroomToggle = value;
                                    progress.setValue("classroomToggle", value);
                                  });
                                },
                                value: classroomToggle,
                                activeThumbImage: const AssetImage(
                                  "assets/img/school-solid.png",
                                ),
                                inactiveThumbImage: const AssetImage("assets/img/school-solid.png"),
                              )),
                        ],
                      ),
                      const Text(
                          "Falls du in die App im Unterricht verwendest, wird Botty dich Schritt-für-Schritt durch die Inhalte führen ☺\nTipp: Natürlich kannst du den Haken natürlich auch einfach so auswählen 🙃")
                    ],
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    ));
  }

  updateName(String text) {
    setState(() {
      name = text;
      progress.setValue("username", name);
      if (text.trim() != "") IntroConsentScreen.changedName = true;
    });
  }

  initProgressModel() async {
    progress = await ProgressModel.getProgressModel();
    progress.setValue("classroomToggle", true);
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
            padding: const EdgeInsets.fromLTRB(32, 32, 32, 16),
            child: Lottie.asset("assets/lottie/feedback.json"),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 16, 12, 16),
            child: Text(
              "Und los geht's! 🚀",
              style: TextStyle(color: BottyColors.darkBlue, fontSize: 24),
            ),
          ),
          const Padding(
            padding: EdgeInsets.fromLTRB(12, 4, 12, 0),
            child: Text(
              "Wir freuen uns, dass du uns dabei hilfst, Botty zu testen. Hoffentlich wirst du dabei genauso viel Spaß haben, wie wir bei der Entwicklung.\n"
              "Bitte lass uns wissen, wie dir die App gefällt!",
              style: TextStyle(color: BottyColors.darkBlue, fontSize: 16),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(12.0),
            child: Text("- dein ITBL-Botty-Team\n(Martin, Delun, Lena, Leonie, Liping und Gereon)"),
          )
        ],
      ),
    ));
  }
}
