import 'package:flutter/cupertino.dart';

class ChorePlan {
  String choreName;
  List<String> participants;
  Map<String, Map<String, String>> directAssignments;
  Map<String, Map<String, String>> finalSchedule;

  ChorePlan({
    required this.choreName,
    required this.participants,
    required this.directAssignments,
    required this.finalSchedule,
  });
}

class ChoreProvider with ChangeNotifier {
  List<ChorePlan> chorePlans = [];
  int? selectedPlanIndex;

  void addChorePlan(ChorePlan chorePlan) {
    chorePlans.add(chorePlan);
    notifyListeners();
  }

  void removeChorePlan(int index) {
    chorePlans.removeAt(index);
    notifyListeners();
  }

  void setSelectedPlan(int index) {
    selectedPlanIndex = index;
    notifyListeners();
  }

  ChorePlan? get selectedPlan =>
      selectedPlanIndex != null ? chorePlans[selectedPlanIndex!] : null;
}
