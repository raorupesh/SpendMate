import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spendmate/models/chore_plan_model.dart';

class ChoreProvider extends ChangeNotifier {
  List<ChorePlan> _chorePlans = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<ChorePlan> get chorePlans => _chorePlans;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Firestore collection reference
  final CollectionReference _choresCollection = FirebaseFirestore.instance.collection('chores');

  // Firebase auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String get currentUserId {
    return _auth.currentUser?.uid ?? '';
  }

  // Initialize the provider and load chore plans for current user
  ChoreProvider() {
    loadChorePlans();
  }

  // Load chore plans from Firebase for the current user
  Future<void> loadChorePlans() async {
    if (currentUserId.isEmpty) {
      _error = "User not logged in";
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Query Firebase for chore plans where userId matches the current user
      QuerySnapshot snapshot = await _choresCollection
          .where('userId', isEqualTo: currentUserId)
          .get();

      // Convert the documents to ChorePlan objects
      _chorePlans = snapshot.docs.map((doc) {
        return ChorePlan.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = "Failed to load chore plans: $e";
      notifyListeners();
    }
  }

  // Add a new chore plan to Firebase
  Future<void> addChorePlan(ChorePlan chorePlan) async {
    if (currentUserId.isEmpty) {
      _error = "User not logged in";
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Add to Firebase
      DocumentReference docRef = await _choresCollection.add(chorePlan.toMap());

      // Create a new ChorePlan with the document ID from Firebase
      ChorePlan newPlan = ChorePlan(
        id: docRef.id,
        userId: chorePlan.userId,
        choreName: chorePlan.choreName,
        participants: chorePlan.participants,
        directAssignments: chorePlan.directAssignments,
        finalSchedule: chorePlan.finalSchedule,
      );

      // Add to local list
      _chorePlans.add(newPlan);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = "Failed to add chore plan: $e";
      notifyListeners();
    }
  }

  // Delete a chore plan from Firebase
  Future<void> deleteChorePlan(String id) async {
    try {
      // Delete from Firebase
      await _choresCollection.doc(id).delete();

      // Delete from local list
      _chorePlans.removeWhere((plan) => plan.id == id);

      notifyListeners();
    } catch (e) {
      _error = "Failed to delete chore plan: $e";
      notifyListeners();
    }
  }

  // Update a chore plan in Firebase
  Future<void> updateChorePlan(ChorePlan plan) async {
    try {
      // Update in Firebase
      await _choresCollection.doc(plan.id).update(plan.toMap());

      // Update in local list
      final index = _chorePlans.indexWhere((p) => p.id == plan.id);
      if (index != -1) {
        _chorePlans[index] = plan;
      }

      notifyListeners();
    } catch (e) {
      _error = "Failed to update chore plan: $e";
      notifyListeners();
    }
  }
}