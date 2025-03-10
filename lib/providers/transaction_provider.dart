import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Transaction {
  String id;
  String groupId;
  String description;
  double amount;
  String paidBy;
  DateTime date;
  Map<String, double> participantShares;
  String category;
  bool isSettled;

  Transaction({
    required this.id,
    required this.groupId,
    required this.description,
    required this.amount,
    required this.paidBy,
    required this.date,
    required this.participantShares,
    required this.category,
    required this.isSettled,
  });

  Map<String, dynamic> toMap() {
    return {
      'groupId': groupId,
      'description': description,
      'amount': amount,
      'paidBy': paidBy,
      'date': Timestamp.fromDate(date),
      'participantShares': participantShares,
      'category': category,
      'isSettled': isSettled,
    };
  }

  factory Transaction.fromMap(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return Transaction(
      id: doc.id,
      groupId: data['groupId'],
      description: data['description'],
      amount: data['amount'],
      paidBy: data['paidBy'],
      date: (data['date'] as Timestamp).toDate(),
      participantShares: Map<String, double>.from(data['participantShares']),
      category: data['category'] ?? "Others",
      isSettled: false,
    );
  }
}

class TransactionProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Transaction> _transactions = [];

  List<Transaction> get transactions => _transactions;

  /// Fetch transactions for a specific group in real-time
  void fetchTransactions(String groupId) {
    _firestore
        .collection('transactions')
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .listen((snapshot) {
      _transactions = snapshot.docs.map((doc) => Transaction.fromMap(doc)).toList();
      notifyListeners();
    });
  }

  /// Add a transaction with category support
  Future<void> addTransaction(
      String groupId,
      String description,
      double amount,
      String paidBy,
      DateTime date,
      Map<String, double> participantShares,
      String category,
      bool isSettled,
      ) async {
    try {
      await _firestore.collection('transactions').add({
        'groupId': groupId,
        'description': description,
        'amount': amount,
        'paidBy': paidBy,
        'date': Timestamp.fromDate(date),
        'participantShares': participantShares,
        'category': category,
        'isSettled': isSettled,
      });
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding transaction: $e');
    }
  }

  /// Delete a transaction
  Future<void> deleteTransaction(String transactionId) async {
    try {
      await _firestore.collection('transactions').doc(transactionId).delete();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting transaction: $e');
    }
  }
}
