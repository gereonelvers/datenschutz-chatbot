import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:survey_kit/survey_kit.dart';

/// This screen contains the survey the user takes at the beginning and end of the campaign/lesson
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
                    onResult: (SurveyResult result) {
                      if (result.finishReason == FinishReason.COMPLETED) {
                        postResult(result);
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
                      appBarTheme: const AppBarTheme(
                        color: Colors.white,
                        iconTheme: IconThemeData(
                          color: Colors.cyan,
                        ),
                        textTheme: TextTheme(
                          button: TextStyle(
                            color: Colors.cyan,
                          ),
                        ),
                      ),
                      iconTheme: const IconThemeData(
                        color: Colors.cyan,
                      ),
                      outlinedButtonTheme: OutlinedButtonThemeData(
                        style: ButtonStyle(
                          minimumSize: MaterialStateProperty.all(
                            Size(150.0, 60.0),
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
          title: 'Welcome to \nBottys survey',
          text:
              'Get ready for a bunch of super interesting questions, so we can get to know each other!',
          buttonText: 'Let\'s go!',
        ),

        //TODO: Add survey questions here
        QuestionStep(
          stepIdentifier: StepIdentifier(id: 'age'),
          title: 'How old are you?',
          answerFormat: IntegerAnswerFormat(),
        ),
        QuestionStep(
          stepIdentifier: StepIdentifier(id: 'gender'),
          title: 'How do you identify yourself?',
          answerFormat: const SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: 'female', value: 'female'),
              TextChoice(text: 'male', value: 'male'),
              TextChoice(text: 'divers', value: 'divers'),
            ],
          ),
        ),
        QuestionStep(
          stepIdentifier: StepIdentifier(id: 'knowledge'),
          title: 'Where do you see your data protection knowledge?',
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
          title: 'Wie oft bist du mit dem Thema schon in Kontakt gekommen',
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
          stepIdentifier: StepIdentifier(id: 'playedBefore'),
          title: 'Hast du je ein (Lern-)Spiel mit einem Chatbot gespielt?',
          answerFormat: const SingleChoiceAnswerFormat(
            textChoices: [
              TextChoice(text: 'ja', value: 'ja'),
              TextChoice(text: 'nö', value: 'nö'),
            ],
          ),
        ),
        QuestionStep(
          stepIdentifier: StepIdentifier(id: 'tellus'),
          title: 'Please tell us a bit about it ;D',
          answerFormat: const TextAnswerFormat(
            maxLines: 5,
            validationRegEx: "^(?!\s*\$).+",
          ),
        ),

        CompletionStep(
          stepIdentifier: StepIdentifier(id: 'completion'),
          text:
              'Thanks for taking the survey, sounds like you are a cool person!',
          title: 'Done!',
          buttonText: 'Submit survey',
        ),
      ],
    );

    //TODO: Add navigation rule
    task.addNavigationRule(
      forTriggerStepIdentifier: task.steps[5].stepIdentifier,
      navigationRule: ConditionalNavigationRule(
        resultToStepIdentifierMapper: (input) {
          switch (input) {
            case 'ja':
              return task.steps[6].stepIdentifier;
            case 'nö':
              return task.steps[7].stepIdentifier;
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

//This one may be needed in the future
/*Future<Task> getJsonTask() async {
    final taskJson = await rootBundle.loadString('assets/example_json.json');
    final taskMap = json.decode(taskJson);

    return Task.fromJson(taskMap);
  }*/
}
