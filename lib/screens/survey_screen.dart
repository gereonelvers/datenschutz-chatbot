import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:survey_kit/survey_kit.dart';

/// This screen contains the survey the user takes at the beginning and end of the campaign/lesson
class IntroSurveyScreen extends StatefulWidget {
  const IntroSurveyScreen({Key? key}) : super(key: key);

  @override
  _IntroSurveyScreenState createState() => _IntroSurveyScreenState();
}

class _IntroSurveyScreenState extends State<IntroSurveyScreen> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          color: Colors.white,
          child: Align(
            alignment: Alignment.center,
            child: FutureBuilder<Task>(
              future: getSampleTask(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    snapshot.data != null) {
                  final task = snapshot.data!;
                  return SurveyKit(
                    onResult: (SurveyResult result) async {
                      if (result.finishReason == FinishReason.COMPLETED) {
                        await postResult(result);
                        goBack();
                      } else {
                        goBack();
                      }
                    },
                    task: task,
                    themeData: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.fromSwatch(
                        primarySwatch: Colors.blueGrey,
                      ).copyWith(
                        onPrimary: Colors.white,
                      ),
                      primaryColor: Colors.blueGrey,
                      backgroundColor: Colors.white,
                      appBarTheme: AppBarTheme(
                        color: Colors.white,
                        iconTheme: const IconThemeData(
                          color: Colors.blueGrey,
                        ), toolbarTextStyle: const TextTheme(
                          button: TextStyle(
                            color: Colors.blueGrey,
                          ),
                        ).bodyText2, titleTextStyle: const TextTheme(
                          button: TextStyle(
                            color: Colors.blueGrey,
                          ),
                        ).headline6,
                      ),
                      iconTheme: const IconThemeData(
                        color: Colors.blueGrey,
                      ),
                      outlinedButtonTheme: OutlinedButtonThemeData(
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(
                            const Size(150.0, 60.0),
                          ),
                          side: MaterialStateProperty.resolveWith(
                            (Set<MaterialState> state) {
                              if (state.contains(MaterialState.disabled)) {
                                return const BorderSide(
                                  color: Colors.grey,
                                );
                              }
                              return const BorderSide(
                                color: Colors.blueGrey,
                              );
                            },
                          ),
                          shape: MaterialStateProperty.all(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          textStyle: MaterialStateProperty.resolveWith(
                            (Set<MaterialState> state) {
                              if (state.contains(MaterialState.disabled)) {
                                return Theme.of(context)
                                    .textTheme
                                    .button
                                    ?.copyWith(
                                      color: Colors.grey,
                                    );
                              }
                              return Theme.of(context)
                                  .textTheme
                                  .button
                                  ?.copyWith(
                                    color: Colors.blueGrey,
                                  );
                            },
                          ),
                        ),
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: ButtonStyle(
                          textStyle: MaterialStateProperty.all(
                            Theme.of(context).textTheme.button?.copyWith(
                                  color: Colors.blueGrey,
                                ),
                          ),
                        ),
                      ),
                    ),
                  );
                }
                return const CircularProgressIndicator.adaptive();
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<Task> getSampleTask() {
    var task = NavigableTask(
      id: TaskIdentifier(),
      steps: [
        InstructionStep(
          stepIdentifier: StepIdentifier(id: 'hello'),
          title: 'Willkommen zur \nBotty Umfrage',
          text:
              'Mach dich bereit für einen Haufen interessanter Fragen, damit wir dich kennenlernen können!',
          buttonText: 'Los geht\'s!',
        ),
        QuestionStep(
          stepIdentifier: StepIdentifier(id: 'age'),
          title: 'Wie alt bist du?',
          answerFormat: const IntegerAnswerFormat(),
        ),
        QuestionStep(
          stepIdentifier: StepIdentifier(id: 'gender'),
          title: 'Wie identifizierst du dich?',
          answerFormat: const SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: 'Schülerin', value: 'female'),
              TextChoice(text: 'Schüler', value: 'male'),
              TextChoice(text: 'Sonstige', value: 'divers'),
              TextChoice(text: 'Keine Angabe', value: 'n/a'),
            ],
          ),
        ),
        QuestionStep(
          stepIdentifier: StepIdentifier(id: 'knowledge'),
          title: 'Wie hoch schätzt du dein Vorwissen über Datenschutz ein? (1 = niedrig, 10 = sehr hoch)',
          answerFormat: const ScaleAnswerFormat(
              step: 1,
              minimumValue: 1,
              maximumValue: 10,
              defaultValue: 5,
              minimumValueDescription: '1',
              maximumValueDescription: '10'),
        ),
        QuestionStep(
          stepIdentifier: StepIdentifier(id: 'contacts'),
          title: 'Wie oft bist du mit dem Thema schon in Kontakt gekommen?',
          answerFormat: const SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: 'nie', value: 'nie'),
              TextChoice(text: 'selten', value: 'selten'),
              TextChoice(text: 'manchmal', value: 'manchmal'),
              TextChoice(text: 'oft', value: 'oft'),
              TextChoice(text: 'ständig', value: 'ständig'),
            ],
          ),
        ),
        QuestionStep(
            stepIdentifier: StepIdentifier(id: 'chatbot_contact'),
            title: 'Hast du schon mal einen Chatbot in Einsatz gesehen? Zum Beispiel auf Websites?',
            answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'ja', value: 'ja'),
                TextChoice(text: 'nein', value: 'nein'),
                TextChoice(text: 'bin mir nicht sicher', value: 'bin mir nicht sicher'),
              ]
            )
        ),
        QuestionStep(
          stepIdentifier: StepIdentifier(id: 'playedBefore'),
          title: 'Hast du je ein (Lern-)Spiel mit einem Chatbot gespielt?',
          answerFormat: const SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: 'ja', value: 'ja'),
              TextChoice(text: 'nein', value: 'nein'),
            ],
          ),
        ),
        QuestionStep(
          stepIdentifier: StepIdentifier(id: 'tellus'),
          title: 'Bitte erzähle uns mehr über dieses Spiel;D',
          answerFormat: const TextAnswerFormat(
            maxLines: 5,
            // ignore: unnecessary_string_escapes
            validationRegEx: "^(?!\s*\$).+",
          ),
        ),

        CompletionStep(
          stepIdentifier: StepIdentifier(id: 'completion'),
          text:
              'Danke für die Teilnahme an der Umfrage!',
          title: 'Fertig!',
          buttonText: 'Umfrage abschicken',
        ),
      ],
    );

    task.addNavigationRule(
      forTriggerStepIdentifier: task.steps[6].stepIdentifier,
      navigationRule: ConditionalNavigationRule(
        resultToStepIdentifierMapper: (input) {
          switch (input) {
            case 'ja':
              return task.steps[7].stepIdentifier;
            case 'nö':
              return task.steps[8].stepIdentifier;
            default:
              return null;
          }
        },
      ),
    );

    return Future.value(task);
  }

  Future<http.Response> postResult(SurveyResult result) {
    var map = <String, dynamic>{};
    for (var res in result.results) {
      if (res.id != null &&
          res.id!.id != "hello" &&
          res.id!.id != "completion") {
        map[res.id!.id] = res.results[0].valueIdentifier;
      }
    }
    return http.post(
        Uri.parse(
            'https://botty-datenschutz.de/wp-json/contact-form-7/v1/contact-forms/155/feedback'),
        body: map);
  }

  goBack()=> Navigator.pop(context);

//This one may be needed in the future
/*Future<Task> getJsonTask() async {
    final taskJson = await rootBundle.loadString('assets/example_json.json');
    final taskMap = json.decode(taskJson);

    return Task.fromJson(taskMap);
  }*/
}
