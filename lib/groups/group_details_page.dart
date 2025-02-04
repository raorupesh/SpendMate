import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/providers/transaction_provider.dart';
import 'package:spendmate/transactions//transaction_details_page.dart';
import 'package:spendmate/transactions//transaction_page.dart';
import 'package:spendmate/groups/group_settings_page.dart';

class GroupDetailPage extends StatelessWidget {
  final String groupName;

  const GroupDetailPage({super.key, required this.groupName});

  @override
  Widget build(BuildContext context) {
    final group = Provider.of<GroupProvider>(context).getGroup(groupName);

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
      body: ListView.builder(
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
}
