import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// This class manages the state of player progression throughout the main quests/campaign
/// TODO: Make observable to make refreshing affected layouts easier?!
/// TODO: Find more scalable way to deal with saving?
///
/// Current checkpoint structure for chapter n:
/// - "startedn" if player started chapter n
/// - "messagedStartedn" if player was messaged after finishing chapter n
/// - "finishedn" if player finished chapter n
/// - "messagedFinishedn" if player was messaged after finishing chapter n
///
/// Usage:
/// - Get an instance through ProgressModel.getProgressModel() in an async method
/// - Get values through getValue() -> This is cheap!
/// - Set values through setValue() -> This is expensive! Check if it really needs to be done!
class ProgressModel {
  Map<String, dynamic> _checkpoints = {};

  // Private constructor to prevent direct instantiation
  ProgressModel._();

  Future<bool> reload() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.getString("checkpoints");
    String checkpointString = sp.getString("checkpoints") ?? "";
    if (checkpointString.isNotEmpty) _checkpoints = jsonDecode(checkpointString);
    return true;
  }

  save() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString("checkpoints", jsonEncode(_checkpoints));
  }

  setValue(String key, bool value) {
    _checkpoints[key] = value;
    save();
  }

  bool getValue(String key) => _checkpoints[key] ?? false;

  reset(){
    _checkpoints = {};
    save();
  }

  // Make ProgressModel available through factory method to force data initialization through SharedPreferences
  static Future<ProgressModel> getProgressModel() async {
    ProgressModel p = ProgressModel._();
    await p.reload();
    return p;
  }

  int getCurrent() {
    if (getValue("finished4")) return 5;
    if (getValue("finished3")) return 4;
    if (getValue("finished2")) return 3;
    if (getValue("finished1")) return 2;
    if (getValue("finished0")) return 1;
    return 0;
  }
}
