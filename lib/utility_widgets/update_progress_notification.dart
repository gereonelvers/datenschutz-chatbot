import 'package:flutter/material.dart';

/// Utility class: Notification that is send to the main PageView (instantiated in main.dart), telling it to rebuild all children to reflect changed progress
class UpdateProgressNotification extends Notification {
  UpdateProgressNotification();
}