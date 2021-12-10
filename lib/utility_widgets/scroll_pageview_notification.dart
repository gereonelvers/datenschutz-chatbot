import 'package:flutter/material.dart';

/// Utility class: Notification that is send to the main PageView (instantiated in main.dart) from one of its children (GameOverviewScreen, ChatScreen, ProfileScreen), telling it to scroll to a certain index
class ScrollPageViewNotification extends Notification {
  final int page;
  ScrollPageViewNotification(this.page);
}