import 'package:flutter/material.dart';

class Transaction {
  String description;
  double amount;
  DateTime date;
  List<String> participants; // List of participants

  Transaction({
    required this.description,
    required this.amount,
    required this.date,
    required this.participants,
  });
}

class Group {
  String name;
  List<String> members;
  List<Transaction> transactions;

  Group({
    required this.name,
    required this.members,
    List<Transaction>? transactions,
  }) : transactions = transactions ?? [];

  // ✅ Calculate balance based on transactions
  double get balance {
    double total = 0.0;
    for (var transaction in transactions) {
      total += transaction.amount;
    }
    return total;
  }
}






class GroupProvider with ChangeNotifier {
  List<Group> _groups = [];

  List<Group> get groups => _groups;

  // Add a new group
  void addGroup(Group group) {
    _groups.add(group);
    notifyListeners();
  }

  void leaveGroup(String groupName) {
    _groups.removeWhere((group) => group.name == groupName);
    notifyListeners();
  }

  void settleUpGroup(String groupName) {
    Group group = _groups.firstWhere((group) => group.name == groupName);
    group.transactions.clear(); // Clear all transactions
    notifyListeners(); // Update UI
  }

  // Add a transaction to a group
  void addTransaction(String groupName, Transaction transaction) {
    // Find the group by name
    Group group = _groups.firstWhere((group) => group.name == groupName);

    // Add the transaction to the group's transaction list (which should be mutable)
    group.transactions.add(transaction);

    // Notify listeners to rebuild UI
    notifyListeners();
  }

  // Get a specific group
  Group getGroup(String groupName) {
    return _groups.firstWhere((group) => group.name == groupName);
  }

  // Update a transaction at the specific index
  void updateTransaction(String groupName, int transactionIndex, Transaction updatedTransaction) {
    final group = _groups.firstWhere((group) => group.name == groupName);
    group.transactions[transactionIndex] = updatedTransaction;
    notifyListeners(); // Notify listeners to rebuild UI
  }

  // Delete a transaction from a group
  void deleteTransaction(String groupName, int transactionIndex) {
    Group group = _groups.firstWhere((group) => group.name == groupName);
    group.transactions.removeAt(transactionIndex);
    notifyListeners(); // Notify listeners to rebuild UI
  }
}
