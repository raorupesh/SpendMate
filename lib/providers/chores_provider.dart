import 'package:flutter/material.dart';

class ChoreProvider with ChangeNotifier {
  int participantCount = 0;
  List<String> participants = [];
  Map<String, Map<String, String>> assignedTasks = {}; // person -> day -> task
  Map<String, Map<String, String>> freeTime = {}; // person -> day -> free time
  Map<String, Map<String, String>> finalSchedule = {}; // person -> day -> assigned task
  bool showGenerateButton = false;
  bool showError = false;
  String assignmentMethod = "";

  final List<String> daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

  void setParticipantCount(int count) {
    participantCount = count;
    participants = List.generate(count, (index) => "Person ${index + 1}");
    assignedTasks.clear();
    freeTime.clear();
    finalSchedule.clear();
    for (var person in participants) {
      assignedTasks[person] = {};
      freeTime[person] = {};
      finalSchedule[person] = {};
    }
    showGenerateButton = false;
    notifyListeners();
  }

  void setAssignmentMethod(String method) {
    assignmentMethod = method;
    showGenerateButton = false;
    showError = false;
    notifyListeners();
  }

  void setFreeTime(String person, String day, String time) {
    freeTime[person]![day] = time;
    checkIfReady();
    notifyListeners();
  }

  void assignTaskDirectly(String person, String day, String task) {
    assignedTasks[person]![day] = task;
    checkIfReady();
    notifyListeners();
  }

  void checkIfReady() {
    bool allAssigned = assignmentMethod == "Enter Free Time"
        ? participants.every((p) => daysOfWeek.every((day) => freeTime[p]![day] != null && freeTime[p]![day]!.isNotEmpty))
        : participants.every((p) => daysOfWeek.every((day) => assignedTasks[p]![day] != null && assignedTasks[p]![day]!.isNotEmpty));

    showGenerateButton = allAssigned;
    showError = !allAssigned;
    notifyListeners();
  }

  bool validateInputs() {
    bool valid = showGenerateButton;
    showError = !valid;
    notifyListeners();
    return valid;
  }

  void generateSchedule() {
    finalSchedule.clear();
    for (var person in participants) {
      for (var day in daysOfWeek) {
        finalSchedule[person]![day] = assignmentMethod == "Enter Free Time"
            ? "Task based on ${freeTime[person]![day]}"
            : assignedTasks[person]![day] ?? "Not Assigned";
      }
    }
    notifyListeners();
  }
}
