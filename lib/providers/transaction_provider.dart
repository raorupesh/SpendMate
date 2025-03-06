import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart'; // Make sure to add this dependency

class Transaction {
  String id;
  String description;
  double amount;
  DateTime date;
  String paidBy; // Added to track who paid
  Map<String, double> participantShares; // Stores split amounts per participant

  Transaction({
    String? id,
    required this.description,
    required this.amount,
    required this.date,
    required this.participantShares,
    required this.paidBy,
  }) : id = id ?? const Uuid().v4();
}

class Group {
  String id;
  String name;
  List<String> members;
  List<Transaction> transactions;
  DateTime createdAt;

  Group({
    String? id,
    required this.name,
    required this.members,
    List<Transaction>? transactions,
    DateTime? createdAt,
  }) :
        id = id ?? const Uuid().v4(),
        transactions = transactions ?? [],
        createdAt = createdAt ?? DateTime.now();

  // Calculate total balance
  double get balance {
    double total = 0.0;
    for (var transaction in transactions) {
      total += transaction.amount;
    }
    return total;
  }

  // Calculate individual balances per member
  Map<String, double> get memberBalances {
    final balances = <String, double>{};

    // Initialize balances for all members
    for (var member in members) {
      balances[member] = 0.0;
    }

    // Calculate based on transactions
    for (var transaction in transactions) {
      // Add what each person paid
      if (balances.containsKey(transaction.paidBy)) {
        balances[transaction.paidBy] = (balances[transaction.paidBy] ?? 0) + transaction.amount;
      }

      // Subtract what each person owes
      for (var entry in transaction.participantShares.entries) {
        if (balances.containsKey(entry.key)) {
          balances[entry.key] = (balances[entry.key] ?? 0) - entry.value;
        }
      }
    }

    return balances;
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

  // Get a group by ID
  Group? getGroupById(String id) {
    try {
      return _groups.firstWhere((group) => group.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get a group by name
  Group getGroup(String groupName) {
    return _groups.firstWhere((group) => group.name == groupName);
  }

  // Update group members
  void updateGroupMembers(String groupId, List<String> updatedMembers) {
    final group = _groups.firstWhere((group) => group.id == groupId);
    group.members = updatedMembers;
    notifyListeners();
  }

  // Leave or delete a group by ID
  void leaveGroup(String groupId) {
    _groups.removeWhere((group) => group.id == groupId);
    notifyListeners();
  }

  // Legacy method - leave group by name (for backward compatibility)
  void leaveGroupByName(String groupName) {
    _groups.removeWhere((group) => group.name == groupName);
    notifyListeners();
  }

  // Settle up all debts in a group
  void settleUpGroup(String groupId) {
    Group? group = getGroupById(groupId);
    if (group != null) {
      group.transactions.clear(); // Clear all transactions
      notifyListeners(); // Update UI
    }
  }

  // Legacy method - settle up by name (for backward compatibility)
  void settleUpGroupByName(String groupName) {
    Group group = _groups.firstWhere((group) => group.name == groupName);
    group.transactions.clear(); // Clear all transactions
    notifyListeners(); // Update UI
  }

  // Add a transaction to a group
  void addTransaction(String groupId, Transaction transaction) {
    // Find the group by ID
    Group? group = getGroupById(groupId);
    if (group != null) {
      // Add the transaction to the group's transaction list
      group.transactions.add(transaction);
      // Notify listeners to rebuild UI
      notifyListeners();
    }
  }

  // Legacy method - add transaction by group name (for backward compatibility)
  void addTransactionByGroupName(String groupName, Transaction transaction) {
    // Find the group by name
    Group group = _groups.firstWhere((group) => group.name == groupName);
    // Add the transaction to the group's transaction list
    group.transactions.add(transaction);
    // Notify listeners to rebuild UI
    notifyListeners();
  }

  // Update a transaction at the specific index
  void updateTransaction(
      String groupId, int transactionIndex, Transaction updatedTransaction) {
    final group = getGroupById(groupId);
    if (group != null && transactionIndex < group.transactions.length) {
      group.transactions[transactionIndex] = updatedTransaction;
      notifyListeners();
    }
  }

  // Legacy method - update transaction by group name (for backward compatibility)
  void updateTransactionByGroupName(
      String groupName, int transactionIndex, Transaction updatedTransaction) {
    final group = _groups.firstWhere((group) => group.name == groupName);
    group.transactions[transactionIndex] = updatedTransaction;
    notifyListeners();
  }

  // Delete a transaction from a group
  void deleteTransaction(String groupId, int transactionIndex) {
    Group? group = getGroupById(groupId);
    if (group != null && transactionIndex < group.transactions.length) {
      group.transactions.removeAt(transactionIndex);
      notifyListeners();
    }
  }

  // Legacy method - delete transaction by group name (for backward compatibility)
  void deleteTransactionByGroupName(String groupName, int transactionIndex) {
    Group group = _groups.firstWhere((group) => group.name == groupName);
    group.transactions.removeAt(transactionIndex);
    notifyListeners();
  }
}