import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class Group {
  String id;
  String name;
  List<String> members;
  DateTime createdAt;

  Group({
    required this.id,
    required this.name,
    required this.members,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'members': members,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Group.fromMap(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Group(
      id: doc.id,
      name: data['name'],
      members: List<String>.from(data['members']),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }
}

class GroupProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Group> _groups = [];
  List<Group> get groups => _groups;

  /// Fetch groups in real-time
  void fetchGroups() {
    _firestore.collection('groups').snapshots().listen((snapshot) {
      _groups = snapshot.docs.map((doc) => Group.fromMap(doc)).toList();
      notifyListeners();
    });
  }

  /// Get a group by name
  Future<Group?> getGroupByName(String groupName) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('groups')
          .where('name', isEqualTo: groupName)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return Group.fromMap(snapshot.docs.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching group: $e');
      return null;
    }
  }

  Future<void> leaveGroup(String groupId, String userId) async {
    final groupRef = FirebaseFirestore.instance.collection('groups').doc(groupId);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final groupSnapshot = await transaction.get(groupRef);
      if (!groupSnapshot.exists) return;

      List<dynamic> members = groupSnapshot.data()?['members'] ?? [];

      if (members.contains("You")) {
        members.remove("You"); // Remove "You" if stored as a string
      }
      if (members.contains(userId)) {
        members.remove(userId); // Remove by actual Firebase User ID if needed
      }

      if (members.isEmpty) {
        transaction.delete(groupRef); // Delete the group if no members remain
      } else {
        transaction.update(groupRef, {'members': members});
      }
    });
  }


  Future<void> updateGroupMembers(String groupId, List<String> updatedMembers) async {
    try {
      DocumentReference groupRef = _firestore.collection('groups').doc(groupId);

      // Fetch all transactions related to the group
      QuerySnapshot transactionSnapshot = await _firestore
          .collection('transactions')
          .where('groupId', isEqualTo: groupId)
          .get();

      // Update transactions by removing removed members
      for (var transaction in transactionSnapshot.docs) {
        Map<String, dynamic> transactionData = transaction.data() as Map<String, dynamic>;

        // Remove participant shares for members who are no longer in the group
        Map<String, dynamic> participantShares = Map.from(transactionData['participantShares']);
        participantShares.removeWhere((key, value) => !updatedMembers.contains(key));

        // Update the transaction in Firestore
        await transaction.reference.update({'participantShares': participantShares});
      }

      // Update the group's members in Firestore
      await groupRef.update({'members': updatedMembers});

      notifyListeners();
    } catch (e) {
      debugPrint('Error updating group members: $e');
    }
  }
  /// Add a new group
  Future<void> addGroup(String groupName, List<String> members,String createdBy) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    try {
      await _firestore.collection('groups').add({
        'name': groupName,
        'members': members, // Add user ID to members list
        'createdBy': createdBy, // Store the user who created the group
        'createdAt': FieldValue.serverTimestamp(),
      });

      notifyListeners();
    } catch (e) {
      print("Error creating group: $e");
    }
  }


  /// Delete a group
  Future<void> deleteGroup(String groupId) async {
    await _firestore.collection('groups').doc(groupId).delete();
    notifyListeners();
  }

  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore.collection('transactions').doc(transactionId).delete();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
    }
  }

}
