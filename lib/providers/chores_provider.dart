import 'package:flutter/cupertino.dart';

class ChoreProvider with ChangeNotifier {
  List<String> participants = [];
  String assignmentMethod = "";
  bool showError = false;

  Map<String, Map<String, String>> directAssignments =
      {}; // { Person -> { Day -> Task } }
  Map<String, Map<String, String>> finalSchedule = {}; // Finalized schedule

  final List<String> daysOfWeek = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

  void setParticipantCount(int count) {
    participants = List.generate(count, (index) => "Person ${index + 1}");
    notifyListeners();
  }

  void setAssignmentMethod(String method) {
    assignmentMethod = method;
    notifyListeners();
  }

  void setDirectAssignments(Map<String, Map<String, String>> assignments) {
    directAssignments = assignments;
    showError = false;
    notifyListeners();
  }

  bool validateInputs() {
    if (assignmentMethod.isEmpty || directAssignments.isEmpty) {
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
        finalSchedule[person]![day] =
            directAssignments[person]?[day] ?? "Not Assigned";
      }
    }
    notifyListeners();
  }
}
