import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/groups/group_settings_page.dart';
import 'package:spendmate/providers/transaction_provider.dart';
import 'package:spendmate/transactions/transaction_details_page.dart';
import 'package:spendmate/transactions/transaction_page.dart';

class GroupDetailPage extends StatefulWidget {
  final String groupName;

  const GroupDetailPage({super.key, required this.groupName});

  @override
  _GroupDetailPageState createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  late List<String> groupMembers;

  @override
  void initState() {
    super.initState();
    final group = Provider.of<GroupProvider>(context, listen: false)
        .getGroup(widget.groupName);
    groupMembers = group.members;
  }

  @override
  Widget build(BuildContext context) {
    final group =
        Provider.of<GroupProvider>(context).getGroup(widget.groupName);

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              // Navigate to Group Settings Page
              final updatedMembers = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupSettingsPage(
                    groupName: widget.groupName,
                    groupMembers: groupMembers, // Pass group members here
                  ),
                ),
              );
              if (updatedMembers != null) {
                setState(() {
                  groupMembers = updatedMembers;
                  group.members = updatedMembers; // Update the group members
                });
              }
            },
          ),
        ],
      ),
      body: group.transactions.isEmpty
          ? const Center(child: Text("No transactions yet."))
          : ListView.builder(
              itemCount: group.transactions.length,
              itemBuilder: (context, index) {
                final transaction = group.transactions[index];
                return Card(
                  child: ListTile(
                    title: Text(transaction.description),
                    subtitle: Text(
                        "Amount: \$${transaction.amount.toStringAsFixed(2)}"),
                    trailing: Text(
                        transaction.date.toLocal().toString().split(' ')[0]),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionDetailsPage(
                            groupName: group.name,
                            transactionIndex:
                                index, // Pass transaction index correctly
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
      // Floating Action Button to Add Transactions
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) =>
                  AddTransactionPage(groupName: widget.groupName),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
