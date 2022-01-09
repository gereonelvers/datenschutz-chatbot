import 'package:datenschutz_chatbot/screens/chat_screen.dart';
import 'package:datenschutz_chatbot/screens/game_overview_screen.dart';
import 'package:datenschutz_chatbot/screens/profile_screen.dart';
import 'package:datenschutz_chatbot/utility_widgets/scroll_pageview_notification.dart';
import 'package:datenschutz_chatbot/utility_widgets/update_progress_notification.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lifecycle/lifecycle.dart';

main() async {
  await Hive.initFlutter();
  runApp(const BottyMainStatelessWidget());
}

/// This is the stateless widget that the main application instantiates.
class BottyMainStatelessWidget extends StatelessWidget {
  const BottyMainStatelessWidget({Key? key}) : super(key: key);

  static const String _title = 'Botty';

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: 1);
    GameOverviewScreen g = GameOverviewScreen(key: UniqueKey());
    ChatScreen c = ChatScreen(key: UniqueKey());
    ProgressScreen p = ProgressScreen(key: UniqueKey());
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitDown,
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    return MaterialApp(
      title: _title,
      home: MaterialApp(
          debugShowCheckedModeBanner: false, // Hiding this as all PageView-children already display one
          navigatorObservers: [defaultLifecycleObserver],
          theme: ThemeData(fontFamily: 'Nexa'),
          home: NotificationListener<ScrollPageViewNotification>(
            onNotification: (n) {
              controller.animateToPage(n.page, duration: const Duration(milliseconds: 200), curve: Curves.ease);
              return true;
            },
            child: NotificationListener<UpdateProgressNotification>(
              onNotification: (n) {
                g = GameOverviewScreen(key: UniqueKey());
                c = ChatScreen(key: UniqueKey());
                p = ProgressScreen(key: UniqueKey());
                return true;
              },
              child: PageView(
                  scrollDirection: Axis.horizontal,
                  controller: controller,
                  children: <Widget>[g,c,p],
                ),
            ),
          ),
      ),
    );
  }
}
