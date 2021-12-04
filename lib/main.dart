import 'package:datenschutz_chatbot/screens/chat_screen.dart';
import 'package:datenschutz_chatbot/screens/game_overview_screen.dart';
import 'package:datenschutz_chatbot/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:lifecycle/lifecycle.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

void main() => runApp(const DataProtectionChatbot());

/// This is the main application widget.
class DataProtectionChatbot extends StatelessWidget {
  const DataProtectionChatbot({Key? key}) : super(key: key);

  static const String _title = 'Datenschutz Chatbot';

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: _title,
      home: SafeArea(
        //appBar: AppBar(title: const Text(_title)),
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
    return MaterialApp(
      debugShowCheckedModeBanner: false, // Hiding this as all PageView-children already display one
      navigatorObservers: [defaultLifecycleObserver],
      theme: ThemeData(fontFamily: 'Nexa'),
      home: Stack(
        children: [
          PageView(
            scrollDirection: Axis.horizontal,
            controller: controller,
            children: const <Widget>[GameOverviewScreen(), ChatScreen(), ProfileScreen()],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 14),
              child: SmoothPageIndicator(
                controller: controller,
                count: 3,
                onDotClicked: (index) {
                  controller.animateToPage(index, duration: const Duration(seconds: 1), curve: Curves.ease);
                },
                effect: const ExpandingDotsEffect(
                  dotColor: Color(0xFF718792),
                  activeDotColor: Color(0xff1c313a),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
