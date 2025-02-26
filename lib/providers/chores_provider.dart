import 'package:flutter/cupertino.dart';

class ChoreProvider with ChangeNotifier {
  List<String> participants = [];
  String choreName = "";
  bool showError = false;
  bool hasSchedule = false; // Track if a schedule exists

  Map<String, Map<String, String>> directAssignments = {}; // { Person -> { Day -> Task } }
  Map<String, Map<String, String>> finalSchedule = {}; // Finalized schedule

  final List<String> daysOfWeek = [
    "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"
  ];

  void setChoreName(String name) {
    choreName = name;
    notifyListeners();
  }

  void setParticipants(List<String> names) {
    participants = names;
    notifyListeners();
  }

  void setDirectAssignments(Map<String, Map<String, String>> assignments) {
    directAssignments = assignments;
    showError = false;
    notifyListeners();
  }

  bool validateInputs() {
    if (choreName.isEmpty || directAssignments.isEmpty || participants.length < 2) {
      showError = true;
      notifyListeners();
      return false;
    }
    return true;
  }

  void generateSchedule() {
    if (!validateInputs()) return;

    finalSchedule.clear();
    for (var person in participants) {
      finalSchedule[person] = {};
      for (var day in daysOfWeek) {
        finalSchedule[person]![day] = directAssignments[person]?[day] ?? "Not Assigned";
      }
    }
    hasSchedule = true; // Mark schedule as created
    notifyListeners();
  }
}
