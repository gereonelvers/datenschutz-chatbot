import 'package:auto_size_text/auto_size_text.dart';
import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:datenschutz_chatbot/utility_widgets/progress_model.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

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
                child: Text("Zurück", style: TextStyle(color: Colors.black)),
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
    setState(() {
      if (controller.page != 0) {
        controller.animateToPage(controller.page!.toInt() - 1, duration: const Duration(milliseconds: 200), curve: Curves.ease);
      }
    });
  }

  forward() {
    setState(() {
      if (controller.page != 2) {
        if (controller.page == 1) {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          if (IntroConsentScreen.CHANGED_NAME) {
            if (IntroConsentScreen.DATA_CONSENT) {
              controller.animateToPage(controller.page!.toInt() + 1, duration: const Duration(milliseconds: 200), curve: Curves.ease);
            } else {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                content: Text("Bitte akzeptiere den Datenschutz-Consent"),
                backgroundColor: Colors.red,
              ));
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Bitte gib deinen Namen an"),
              backgroundColor: Colors.red,
            ));
          }
        } else {
          controller.animateToPage(controller.page!.toInt() + 1, duration: const Duration(milliseconds: 200), curve: Curves.ease);
        }
      } else {
        exitIntro();
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
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 32),
            child: Text(
              "Willkommen!",
              style: TextStyle(color: BottyColors.darkBlue, fontSize: 32),
            ),
          ),
          Material(
            elevation: 20,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(45))),
            child: InkWell(
              onTap: (){},
              borderRadius: BorderRadius.all(Radius.circular(45)),
              child: Image.asset(
                "assets/img/data-white.png",
                height: 180,
                width: 180,
                color: BottyColors.darkBlue,
              ),
            ),
            color: Colors.white,
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
  static bool CHANGED_NAME = false;

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
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
            child: Text(
              "📝 Erstmal der Papierkram...",
              style: TextStyle(color: BottyColors.darkBlue, fontSize: 24),
            ),
          ),
          Stepper(
            controlsBuilder: (BuildContext context, {VoidCallback? onStepContinue, VoidCallback? onStepCancel}) {
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Visibility(
                  visible: !(_index==2),
                  child: Row(
                    children: <Widget>[
                      Visibility(
                        visible: !(_index==0),
                        child: TextButton(
                          onPressed: onStepCancel,
                          child: Text(
                            'Zurück',
                            style: TextStyle(color: BottyColors.darkBlue),
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: onStepContinue,
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color>(
                              BottyColors.blue,
                            ),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15.0),
                            ))),
                        child: Padding(
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
            physics: const BouncingScrollPhysics(),
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
                            borderSide: BorderSide(color: BottyColors.darkBlue),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                            borderSide: BorderSide(color: BottyColors.darkBlue),
                          ),
                          labelText: "Name",
                          labelStyle: TextStyle(color: BottyColors.darkBlue)
                      ),
                      onChanged: updateName,
                    ),
                  ],
                ),
                //state: StepState.complete
              ),
              Step(
                  title: Text("📜 Datenschutzerklärung", style: TextStyle(fontSize: 18)),
                  content: Column(
                    children: [
                      SizedBox(
                        height: 250,
                          child: SingleChildScrollView(
                            physics: BouncingScrollPhysics(),
                              child: Text("Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet. Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam erat, sed diam voluptua. At vero eos et accusam et justo duo dolores et ea rebum. Stet clita kasd gubergren, no sea takimata sanctus est Lorem ipsum dolor sit amet."))),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0,16,0,0),
                        child: Row(
                            children: [
                            Expanded(
                            flex: 1,
                            child: Checkbox(
                              value: IntroConsentScreen.DATA_CONSENT, onChanged: (bool? value) {
                              setState(() {
                                IntroConsentScreen.DATA_CONSENT = !IntroConsentScreen.DATA_CONSENT;
                              });
                            },
                              activeColor: BottyColors.darkBlue,
                            ),
                          ),
                          Flexible(
                              flex: 4,
                              child: Wrap(
                                children: [Text("Ich habe die Datenschutzerklärung gelesen und stimme ihr zu.",),],
                              ),
                            )
                        ]),
                      )
                    ],
                  )),
              Step(
                  title: Text("🎮 Spielmodus", style: TextStyle(fontSize: 18)),
                  content: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState((){
                                classroomToggle = !classroomToggle;
                                progress.setValue("classroomToggle", classroomToggle);
                              });
                            },
                            child: Text(
                              "Spielst du in der Klasse?",
                              style: TextStyle(color: BottyColors.darkBlue, fontSize: 16),
                            ),
                          ), const Spacer(),
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
                                activeThumbImage: const AssetImage("assets/img/school-solid.png",),
                                inactiveThumbImage: const AssetImage("assets/img/school-solid.png"),
                              )
                          ),
                        ],
                      ),
                      Text("Falls du in die App im Unterricht verwendest, wird Botty dich Schritt-für-Schritt durch die Inhalte führen ☺\nTipp: Natürlich kannst du den Haken natürlich auch einfach so auswählen 🙃")
                    ],
                  ),),
            ],
          )
        ],
      ),
    ));
  }

  updateName(String text) {
    setState(() {
      name = text;
      progress.setValue("username", name);
      if(text.trim()!="") IntroConsentScreen.CHANGED_NAME = true;
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
            padding: const EdgeInsets.fromLTRB(32,32,32,16),
            child: Lottie.asset("assets/lottie/feedback.json"),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
            child: Text(
              "Und los geht's! 🚀",
              style: TextStyle(color: BottyColors.darkBlue, fontSize: 24),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
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
