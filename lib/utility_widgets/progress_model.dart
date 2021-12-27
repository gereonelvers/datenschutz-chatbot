import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

/// This class manages the state of player progression throughout the main quests/campaign
/// It does this by basically acting like a convenience wrapper around a Hive box containing all values.
/// TODO: Make observable to make refreshing affected layouts easier?!
///
/// Current checkpoint structure for chapter n:
/// - "startedn" if player started chapter n
/// - "messagedStartedn" if player was messaged after finishing chapter n
/// - "finishedn" if player finished chapter n
/// - "messagedFinishedn" if player was messaged after finishing chapter n
///
class ProgressModel {
  late Box progress;

  // Private constructor to prevent direct instantiation
  ProgressModel._();

  Future<bool> reload() async {
    progress = await Hive.openBox('progressBox');
    return true;
  }


  setValue(String key, var value) => progress.put(key, value);

  bool getBool(String key) => progress.get(key, defaultValue: false);
  int getInt(String key) => progress.get(key, defaultValue: 0);
  String getString(String key) => progress.get(key, defaultValue: "");
  Color getColor(String key) => progress.get(key, defaultValue: Colors.white);

  reset() => progress.clear();

  // Make ProgressModel available through factory method to force data initialization through SharedPreferences
  static Future<ProgressModel> getProgressModel() async {
    ProgressModel p = ProgressModel._();
    await p.reload();
    return p;
  }

  int getCurrentChapter() {
    if (getBool("finished4")) return 5;
    if (getBool("finished3")) return 4;
    if (getBool("finished2")) return 3;
    if (getBool("finished1")) return 2;
    if (getBool("finished0")) return 1;
    return 0;
  }
}
