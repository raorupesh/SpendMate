import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/providers/transaction_provider.dart';
import 'package:spendmate/screens/group_settings_page.dart';
import 'package:spendmate/screens/transaction_details_page.dart';
import 'package:spendmate/screens/transaction_page.dart';

class GroupDetailPage extends StatelessWidget {
  final String groupName;

  const GroupDetailPage({super.key, required this.groupName});

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final group = groupProvider.getGroup(groupName);

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // Navigate to Group Settings Page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupSettingsPage(groupName: groupName),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: group.transactions.length,
              itemBuilder: (context, index) {
                final transaction = group.transactions[index];
                return Card(
                  child: ListTile(
                    title: Text(transaction.description),
                    subtitle: Text("Amount: \$${transaction.amount.toStringAsFixed(2)}"),
                    trailing: Text(transaction.date.toLocal().toString().split(' ')[0]),
                    onTap: () {
                      // Navigate to Transaction Details Page
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionDetailsPage(
                            groupName: group.name,
                            transactionIndex: index,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          _buildBalanceSection(group),
          const SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            onPressed: () {
              _settleUp(context, groupProvider, groupName);
            },
            child: const Text("Settle Up"),
          ),
          const SizedBox(height: 20),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to Add Transaction page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTransactionPage(groupName: groupName),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBalanceSection(Group group) {
    return Column(
      children: [
        Text(
          group.balance < 0
              ? "You owe \$${group.balance.abs().toStringAsFixed(2)}"
              : "You are owed \$${group.balance.toStringAsFixed(2)}",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: group.balance < 0 ? Colors.red : Colors.green,
          ),
        ),
      ],
    );
  }

  void _settleUp(BuildContext context, GroupProvider groupProvider, String groupName) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Settle Up"),
          content: const Text("Are you sure you want to settle up all transactions?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                groupProvider.settleUpGroup(groupName);
                Navigator.pop(context); // Close dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Group settled successfully!")),
                );
              },
              child: const Text("Settle Up", style: TextStyle(color: Colors.green)),
            ),
          ],
        );
      },
    );
  }
}
