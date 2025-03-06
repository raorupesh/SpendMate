import 'package:flutter/foundation.dart';

class ChorePlan {
  final String choreName;
  final List<String> participants;
  final Map<String, Map<String, String>> directAssignments;
  final Map<String, dynamic> finalSchedule;

  ChorePlan({
    required this.choreName,
    required this.participants,
    required this.directAssignments,
    required this.finalSchedule,
  });
}

class ChoreProvider extends ChangeNotifier {
  final List<ChorePlan> _chorePlans = [];

  List<ChorePlan> get chorePlans => _chorePlans;

  void addChorePlan(ChorePlan plan) {
    _chorePlans.add(plan);
    notifyListeners();
  }

  // Delete a chore plan
  void deleteChorePlan(int index) {
    if (index >= 0 && index < _chorePlans.length) {
      _chorePlans.removeAt(index);
      notifyListeners();
    }
  }

  // Get a specific chore plan
  ChorePlan? getChorePlan(int index) {
    if (index >= 0 && index < _chorePlans.length) {
      return _chorePlans[index];
    }
    return null;
  }
}