import 'package:datenschutz_chatbot/screens/chat_screen.dart';
import 'package:datenschutz_chatbot/screens/game_overview_screen.dart';
import 'package:datenschutz_chatbot/screens/profile_screen.dart';
import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:datenschutz_chatbot/utility_widgets/scroll_pageview_notification.dart';
import 'package:datenschutz_chatbot/utility_widgets/update_progress_notification.dart';
import 'package:flutter/material.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

main() => runApp(const DataProtectionChatbot());

/// This is the main application widget.
class DataProtectionChatbot extends StatelessWidget {
  const DataProtectionChatbot({Key? key}) : super(key: key);

  static const String _title = 'Botty';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: SafeArea(
        child: MainStatelessWidget(),
      ),
    );
  }
}

/// This is the stateless widget that the main application instantiates.
class MainStatelessWidget extends StatelessWidget {
  const MainStatelessWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PageController controller = PageController(initialPage: 1);
    GameOverviewScreen g = GameOverviewScreen(key: UniqueKey());
    ChatScreen c = ChatScreen(key: UniqueKey());
    ProfileScreen p = ProfileScreen(key: UniqueKey());
    return MaterialApp(
        debugShowCheckedModeBanner: false, // Hiding this as all PageView-children already display one
        navigatorObservers: [defaultLifecycleObserver],
        theme: ThemeData(fontFamily: 'Nexa'),
        home: Stack(
          children: [
            NotificationListener<ScrollPageViewNotification>(
              onNotification: (n) {
                controller.animateToPage(n.page, duration: const Duration(milliseconds: 200), curve: Curves.ease);
                return true;
              },
              child: NotificationListener<UpdateProgressNotification>(
                onNotification: (n) {
                  print("Told widgets to rebuild");
                  g = GameOverviewScreen(key: UniqueKey());
                  c = ChatScreen(key: UniqueKey());
                  p = ProfileScreen(key: UniqueKey());
                  return true;
                },
                child: PageView(
                    scrollDirection: Axis.horizontal,
                    controller: controller,
                    children: <Widget>[g,c,p],
                  ),
              ),
            ),
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
                child: SmoothPageIndicator(
                  controller: controller,
                  count: 3,
                  onDotClicked: (index) {
                    controller.animateToPage(index, duration: const Duration(milliseconds: 200), curve: Curves.ease);
                  },
                  effect: ExpandingDotsEffect(
                    dotColor: BottyColors.lightBlue,
                    activeDotColor: BottyColors.darkBlue,
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}
