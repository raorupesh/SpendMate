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

  Future<void> leaveGroup(String groupId, String userName) async {
    try {
      DocumentReference groupRef = _firestore.collection('groups').doc(groupId);
      DocumentSnapshot groupDoc = await groupRef.get();

      if (groupDoc.exists) {
        List<dynamic> members = groupDoc['members'];

        // Remove the user from the group
        if (members.contains(userName)) {
          members.remove(userName);

          if (members.isEmpty) {
            // If no members left, delete the group
            await groupRef.delete();
          } else {
            // Otherwise, update the group
            await groupRef.update({'members': members});
          }

          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error leaving group: $e');
    }
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
  Future<void> addGroup(String groupName, List<String> members) async {
    try {
      String groupId = const Uuid().v4();
      await _firestore.collection('groups').doc(groupId).set({
        'id': groupId,
        'name': groupName,
        'members': members,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Error adding group: $e');
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
