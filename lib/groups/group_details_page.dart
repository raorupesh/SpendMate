import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/groups/group_settings_page.dart';
import 'package:spendmate/providers/transaction_provider.dart';
import 'package:spendmate/transactions/transaction_details_page.dart';
import 'package:spendmate/transactions/add_transaction_page.dart';


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
    // We need to use Provider.of<GroupProvider>(context, listen: false) in initState
    final group = Provider.of<GroupProvider>(context, listen: false)
        .getGroup(widget.groupName);
    groupMembers = group.members;
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final group = groupProvider.getGroup(widget.groupName);

    return Scaffold(
      appBar: AppBar(
        title: Text(group.name),
        backgroundColor: Colors.teal,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              // Navigate to Group Settings Page
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => GroupSettingsPage(
                    groupId: group.id, // Pass group ID
                    groupName: widget.groupName,
                    groupMembers: groupMembers,
                    onLeaveGroup: (groupId) {
                      // Handle group leaving in provider
                      groupProvider.leaveGroup(groupId);
                    },
                  ),
                ),
              );

              // Handle the result
              if (result != null) {
                if (result['action'] == 'leave') {
                  // If user left the group, navigate back to groups list
                  Navigator.of(context).pop();
                } else if (result['action'] == 'update' && result['members'] != null) {
                  // If members were updated
                  setState(() {
                    groupMembers = List<String>.from(result['members']);
                    group.members = List<String>.from(result['members']); // Update the group members
                  });
                }
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Group summary card
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Members: ${group.members.length}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Transactions: ${group.transactions.length}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Total: \$${_calculateTotal(group.transactions).toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Transactions header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: const [
                Text(
                  "Recent Transactions",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Spacer(),
                Text(
                  "Tap for details",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          // Transactions list
          Expanded(
            child: group.transactions.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  const Text(
                    "No transactions yet",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    icon: const Icon(Icons.add_circle_outline),
                    label: const Text("Add your first transaction"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddTransactionPage(groupName: widget.groupName),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: group.transactions.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final transaction = group.transactions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  elevation: 1,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade50,
                      child: Icon(
                        Icons.receipt,
                        color: Colors.teal.shade700,
                      ),
                    ),
                    title: Text(
                      transaction.description,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      "Paid by: ${transaction.paidBy}",
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "\$${transaction.amount.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _formatDate(transaction.date),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
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
        ],
      ),
      // Floating Action Button to Add Transactions
      floatingActionButton: FloatingActionButton.extended(
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
        icon: const Icon(Icons.add),
        label: const Text("Add Expense"),
      ),
    );
  }

  // Helper method to calculate total amount
  double _calculateTotal(List<Transaction> transactions) {
    double total = 0;
    for (var transaction in transactions) {
      total += transaction.amount;
    }
    return total;
  }

  // Helper method to format date
  String _formatDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }
}