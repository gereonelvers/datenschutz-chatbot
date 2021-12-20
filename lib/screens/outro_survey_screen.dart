import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:survey_kit/survey_kit.dart';

/// This screen contains the survey the user takes at the end of the campaign/lesson
/// TODO: Everything :)
class SurveyScreen extends StatefulWidget {
  const SurveyScreen({Key? key}) : super(key: key);

  @override
  _SurveyScreenState createState() => _SurveyScreenState();
}

class _SurveyScreenState extends State<SurveyScreen> {
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
                      }
                    },
                    task: task,
                    themeData: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.fromSwatch(
                        primarySwatch: Colors.cyan,
                      ).copyWith(
                        onPrimary: Colors.white,
                      ),
                      primaryColor: Colors.cyan,
                      backgroundColor: Colors.white,
                      appBarTheme: AppBarTheme(
                        color: Colors.white,
                        iconTheme: const IconThemeData(
                          color: Colors.cyan,
                        ), toolbarTextStyle: const TextTheme(
                        button: TextStyle(
                          color: Colors.cyan,
                        ),
                      ).bodyText2, titleTextStyle: const TextTheme(
                        button: TextStyle(
                          color: Colors.cyan,
                        ),
                      ).headline6,
                      ),
                      iconTheme: const IconThemeData(
                        color: Colors.cyan,
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
                                color: Colors.cyan,
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
                                color: Colors.cyan,
                              );
                            },
                          ),
                        ),
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: ButtonStyle(
                          textStyle: MaterialStateProperty.all(
                            Theme.of(context).textTheme.button?.copyWith(
                              color: Colors.cyan,
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

        //TODO: Add survey questions here
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
              minimumValueDescription: 'sehr unwahrscheinlich',
              maximumValueDescription: 'sehr wahrscheinlich'),
        ),
        QuestionStep(
          stepIdentifier: StepIdentifier(id: 'Botty_advice'),
          title: 'Würdest du Botty in Zukunft nochmal um Rat fragen?',
          answerFormat: const SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: 'ja', value: 'ja'),
              TextChoice(text: 'nein', value: 'nein'),
              TextChoice(text: 'vielleicht', value: 'vielleicht'),
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
          stepIdentifier: StepIdentifier(id: 'Erlaubnistatbestände'),
          title: 'Könntest du jetzt erklären, was Erlaubnistatbestände sind?',
          answerFormat: const SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: 'ja', value: 'ja'),
              TextChoice(text: 'nein', value: 'nein'),
              TextChoice(text: 'vielleicht', value: 'vielleicht'),
            ],
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

}