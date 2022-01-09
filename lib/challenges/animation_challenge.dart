import 'package:datenschutz_chatbot/challenges/challenge.dart';
import 'package:datenschutz_chatbot/utility_widgets/botty_colors.dart';
import 'package:datenschutz_chatbot/utility_widgets/challenge_result_notification.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

/// Implementation of Challenge that displays an animation and then automatically skips forward
class IntroAnimationChallenge extends Challenge {

  const IntroAnimationChallenge({Key? key}) : super(key: key);


  @override
  _AnimationChallengeState createState() => _AnimationChallengeState();
}

class _AnimationChallengeState extends ChallengeState<IntroAnimationChallenge> with TickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) {
      if(status == AnimationStatus.completed) {
        submit();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
              flex: 10,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24,0,24,32),
                child: Lottie.asset("assets/lottie/door-opening.json",
                  controller: _controller,
                  reverse: true,
                  onLoaded: (composition) {
                    // Configure the AnimationController with the duration of the
                    // Lottie file and start the animation.
                    _controller
                      ..duration = composition.duration
                      ..forward();
                  },
                ),
              ),),
        ],
      ),
    );
  }

  @override
  void submit() {
    // Dispatch notification to let ChallengeWrapper know of challenge result
    ChallengeResultNotification(true).dispatch(context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}