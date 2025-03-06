import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/providers/transaction_provider.dart';
import 'package:intl/intl.dart'; // Import intl for date formatting

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
        elevation: 2, // Add subtle shadow
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              _showDeleteConfirmationDialog(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView( // Make the body scrollable
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card( // Wrap content in a Card for a cleaner look
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow("Description:", transaction.description),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    "Amount:",
                    "\$${transaction.amount.toStringAsFixed(2)}",
                    valueColor: transaction.amount < 0 ? Colors.red : Colors.green,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    "Date:",
                    DateFormat('EEEE, MMMM d, y').format(transaction.date.toLocal()), // Format date
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 10),
                  const Text("Participants & Contributions:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  transaction.participantShares.isNotEmpty
                      ? ListView.separated( // Use ListView.separated for better list rendering
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(), // Disable scrolling within the ListView
                    itemCount: transaction.participantShares.length,
                    separatorBuilder: (context, index) => const Divider(),
                    itemBuilder: (context, index) {
                      final entry = transaction.participantShares.entries.elementAt(index);
                      return ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(entry.key),
                        trailing: Text("\$${entry.value.toStringAsFixed(2)}"),
                      );
                    },
                  )
                      : const Text(
                    "No participants added.",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(
          value,
          style: TextStyle(fontSize: 16, color: valueColor),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Transaction"),
          content: const Text("Are you sure you want to delete this transaction?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Provider.of<GroupProvider>(context, listen: false)
                    .deleteTransaction(groupName, transactionIndex);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}