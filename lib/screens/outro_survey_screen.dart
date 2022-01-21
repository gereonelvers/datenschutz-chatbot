import 'package:datenschutz_chatbot/utility_widgets/progress_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:survey_kit/survey_kit.dart';

/// This screen contains the survey the user takes at the end of the campaign/lesson
class OutroSurveyScreen extends StatefulWidget {
  const OutroSurveyScreen({Key? key}) : super(key: key);

  @override
  _OutroSurveyScreenState createState() => _OutroSurveyScreenState();
}

class _OutroSurveyScreenState extends State<OutroSurveyScreen> {
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
                      } else{
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
          title: 'Willkommen zur letzten \nBotty Umfrage',
          text:
          'Es war eine Freude, mit dir zu lernen. Erzählst du uns von deinen Erfahrungen?',
          buttonText: 'Los geht\'s!',
        ),

        QuestionStep(
          stepIdentifier: StepIdentifier(id: 'time'),
          title: 'Wie lange hast du unsere App genutzt?',
          answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'zwischen 10 und 20 Minuten', value: 'kurz'),
                TextChoice(text: 'zwischen 20 und 40 Minuten', value: 'mittellang'),
                TextChoice(text: 'zwischen 40 und 60 Minuten', value: 'lang'),
                TextChoice(text: 'zwischen 60 und 90 Minuten', value: 'sehr lang')
              ]
          ),
        ),
        QuestionStep(
          stepIdentifier: StepIdentifier(id: 'better_knowledge'),
          title: 'Hast du mit Hilfe der App mehr über Datenschutz gelernt?',
          answerFormat: const SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: 'sehr', value: 'sehr'),
              TextChoice(text: 'ein bisschen', value: 'ein bisschen'),
              TextChoice(text: 'kaum', value: 'kaum'),
              TextChoice(text: 'gar nicht', value: 'gar nicht'),
            ],
          ),
        ),
        QuestionStep(
          stepIdentifier: StepIdentifier(id: 'app_grading'),
          title: 'Welche Schulnote würdest du dem Einsatz des Chatbots geben?',
          answerFormat: const ScaleAnswerFormat(
              step: 1,
              minimumValue: 1,
              maximumValue: 6,
              defaultValue: 3,
              minimumValueDescription: '1',
              maximumValueDescription: '6'),
        ),
        QuestionStep(
          stepIdentifier: StepIdentifier(id: 'app_recommendation'),
          title: 'Wie wahrscheinlich würdest du Botty einem Freund/ einer Freundin empfehlen?',
          answerFormat: const ScaleAnswerFormat(
              step: 1,
              minimumValue: 1,
              maximumValue: 6,
              defaultValue: 3,
              minimumValueDescription: 'sehr wahrscheinlich',
              maximumValueDescription: 'sehr unwahrscheinlich'),
        ),
        QuestionStep(
          stepIdentifier: StepIdentifier(id: 'Botty_advice'),
          title: 'Würdest du Botty in Zukunft nochmal um Rat fragen?',
          answerFormat: const SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: 'ja', value: 'ja'),
              TextChoice(text: 'nein', value: 'nein'),
              TextChoice(text: 'vielleicht', value: 'vielleicht'),
              TextChoice(text: 'weiß ich nicht', value: 'weiß ich nicht'),
            ],
          ),
        ),
        QuestionStep(
            stepIdentifier: StepIdentifier(id: 'app_complexity'),
            title: 'Wie komplex fandest du die App?',
            answerFormat: const ScaleAnswerFormat(
              step: 1,
              minimumValue: 1,
              maximumValue: 6,
              defaultValue: 3,
              minimumValueDescription: 'gar nicht komplex',
              maximumValueDescription: 'viel zu komplex'),
        ),
        QuestionStep(
          stepIdentifier: StepIdentifier(id: 'Erlaubnistatbestaende'),
          title: 'Könntest du jetzt erklären, was Erlaubnistatbestände sind?',
          answerFormat: const SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: 'ja', value: 'ja'),
              TextChoice(text: 'nein', value: 'nein'),
              TextChoice(text: 'vielleicht', value: 'vielleicht'),
            ],
          ),
        ),
        QuestionStep(
          stepIdentifier: StepIdentifier(id: "Langzeitgedaechtnis"),
          title: 'Glaubst du, dass du das erlernte Wissen auch in zwei Wochen noch abrufen kannst?',
          answerFormat: const SingleChoiceAnswerFormat(
              textChoices: [
                TextChoice(text: 'ja', value: 'ja'),
                TextChoice(text: 'nein', value: 'nein'),
                TextChoice(text: 'vielleicht', value: 'vielleicht'),
              ],
          ),
        ),
        QuestionStep(
          stepIdentifier: StepIdentifier(id: "Structure"),
          title: 'Findest du, unsere App war klar strukturiert?',
          answerFormat: const SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: 'ja', value: 'ja'),
              TextChoice(text: 'nein', value: 'nein'),
              TextChoice(text: 'was dazwischen', value: 'was dazwischen'),
            ],
          ),
        ),
        QuestionStep(
          stepIdentifier: StepIdentifier(id: "text_size"),
          title: 'Wie fandest du die Länge der Texte?',
          answerFormat: const SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: 'zu kurz', value: 'zu kurz'),
              TextChoice(text: 'eher zu kurz', value: 'eher zu kurz'),
              TextChoice(text: 'eher zu lang', value: 'eher zu lang'),
              TextChoice(text: 'zu lang', value: 'zu lang'),
            ],
          ),
        ),
        QuestionStep(
          stepIdentifier: StepIdentifier(id: "emojies"),
          title: 'Der Einsatz von Emojies...',
          answerFormat: const SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: 'hat mich positiv beeinflusst', value: 'positive'),
              TextChoice(text: 'hat mich nicht beeinflusst', value: 'neutral'),
              TextChoice(text: 'hat mich negativ beeinflusst', value: 'negative'),
            ],
          ),
        ),
        QuestionStep(
          stepIdentifier: StepIdentifier(id: "motivation"),
          title: 'Hast du Lust, dich noch mehr mit dem Thema auseinanderzusetzen?',
          answerFormat: const SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: 'ja', value: 'ja'),
              TextChoice(text: 'nein', value: 'nein'),
              TextChoice(text: 'vielleicht', value: 'vielleicht'),
            ],
          ),
        ),
        QuestionStep(
          stepIdentifier: StepIdentifier(id: 'tellus'),
          title: 'Wir freuen uns über weiteres Feedback!',
          isOptional: true,
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

    /*//TODO: Add navigation rule
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
    );*/

    return Future.value(task);
  }

  Future<http.Response> postResult(SurveyResult result) async {
    var map = <String, dynamic>{};
    for (var res in result.results) {
      if (res.id != null &&
          res.id!.id != "hello" &&
          res.id!.id != "completion") {
        map[res.id!.id] = res.results[0].valueIdentifier;
      }
    }
    ProgressModel p = await ProgressModel.getProgressModel();
    map["sessionID"] = p.getString("sessionID");
    return http.post(
        Uri.parse(
            'https://botty-datenschutz.de/wp-json/contact-form-7/v1/contact-forms/231/feedback'),
        body: map);
  }

  goBack()=> Navigator.pop(context);

}