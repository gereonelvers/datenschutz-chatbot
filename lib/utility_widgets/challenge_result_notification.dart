import 'package:flutter/material.dart';

/// Utility class: Notification that is send between Challenges and ChallengeWrapper once a challenge is completed
class ChallengeResultNotification extends Notification {
  final bool result;
  ChallengeResultNotification(this.result);
}