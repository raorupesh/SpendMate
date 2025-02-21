import 'package:flutter/material.dart';

class ChoreProvider with ChangeNotifier {
  int participantCount = 0;
  List<String> participants = [];
  Map<String, String> assignedTasks = {};
  Map<String, String> freeTime = {};
  Map<String, String> finalSchedule = {};
  bool showGenerateButton = false;
  bool showError = false;
  String assignmentMethod = "";

  void setParticipantCount(int count) {
    participantCount = count;
    participants = List.generate(count, (index) => "Person ${index + 1}");
    assignedTasks.clear();
    freeTime.clear();
    finalSchedule.clear();
    showGenerateButton = false;
    notifyListeners();
  }

  void setAssignmentMethod(String method) {
    assignmentMethod = method;
    showGenerateButton = false; // Reset the button visibility
    showError = false;
    notifyListeners();
  }

  void setFreeTime(String person, String time) {
    freeTime[person] = time;
    checkIfReady();
    notifyListeners();
  }

  void assignTaskDirectly(String person, String task) {
    assignedTasks[person] = task;
    checkIfReady();
    notifyListeners();
  }

  void checkIfReady() {
    // Check if all tasks or free times are filled
    bool allAssigned = assignmentMethod == "Enter Free Time"
        ? participants.every((p) => freeTime.containsKey(p) && freeTime[p]!.isNotEmpty)
        : participants.every((p) => assignedTasks.containsKey(p) && assignedTasks[p]!.isNotEmpty);

    showGenerateButton = allAssigned;
    showError = !allAssigned;
    notifyListeners();
  }

  bool validateInputs() {
    // Ensure all inputs are filled before generating schedule
    bool valid = showGenerateButton;
    showError = !valid;
    notifyListeners();
    return valid;
  }

  void generateSchedule() {
    finalSchedule.clear();

    if (assignmentMethod == "Enter Free Time") {
      List<String> tasks = ["Cleaning", "Dishes", "Cooking", "Laundry", "Trash", "Other"];
      int i = 0;
      freeTime.forEach((person, time) {
        finalSchedule[person] = tasks[i % tasks.length];
        i++;
      });
    } else {
      finalSchedule.addAll(assignedTasks);
    }

    notifyListeners();
  }
}
