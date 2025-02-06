import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/providers/transaction_provider.dart';

class TransactionDetailsPage extends StatelessWidget {
  final String groupName;
  final int transactionIndex;

  const TransactionDetailsPage({
    super.key,
    required this.groupName,
    required this.transactionIndex,
  });

  @override
  Widget build(BuildContext context) {
    final group = Provider.of<GroupProvider>(context).getGroup(groupName);
    final transaction = group.transactions[transactionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction Details"),
        backgroundColor: Colors.teal,
        actions: [
          // ✅ Delete button to remove transaction
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Description:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(transaction.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 12),

            const Text("Amount:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("\$${transaction.amount.toStringAsFixed(2)}",
                style: TextStyle(
                    fontSize: 16,
                    color: transaction.amount < 0 ? Colors.red : Colors.green)),
            const SizedBox(height: 12),

            const Text("Date:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text(transaction.date.toLocal().toString().split(' ')[0],
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 20),

            const Divider(),
            const SizedBox(height: 10),

            const Text("Participants:",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // ✅ Show participants only if they exist
            transaction.participants.isNotEmpty
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: transaction.participants
                  .map((participant) => ListTile(
                leading: const Icon(Icons.person),
                title: Text(participant),
              ))
                  .toList(),
            )
                : const Text(
              "No participants added.",
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Confirmation dialog for deleting a transaction
  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Transaction"),
          content: const Text("Are you sure you want to delete this transaction?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Cancel
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Provider.of<GroupProvider>(context, listen: false)
                    .deleteTransaction(groupName, transactionIndex);
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to group details
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
