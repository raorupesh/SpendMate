import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/groups/group_settings_page.dart';
import 'package:spendmate/providers/group_provider.dart';
import 'package:spendmate/providers/transaction_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:spendmate/transactions/add_transaction_page.dart';
import 'package:spendmate/transactions/transaction_details_page.dart';

class GroupDetailPage extends StatefulWidget {
  final String groupName;

  const GroupDetailPage({super.key, required this.groupName});

  @override
  _GroupDetailPageState createState() => _GroupDetailPageState();
}

class _GroupDetailPageState extends State<GroupDetailPage> {
  String? groupId;
  List<String> _groupMembers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchGroupDetails();
  }

  /// Fetches group details from Firestore
  Future<void> _fetchGroupDetails() async {
    final group = await Provider.of<GroupProvider>(context, listen: false)
        .getGroupByName(widget.groupName);

    if (group != null) {
      setState(() {
        groupId = group.id;
        _groupMembers = List<String>.from(group.members);
        isLoading = false;
      });

      // Fetch transactions only if groupId is available
      if (groupId != null) {
        Provider.of<TransactionProvider>(context, listen: false)
            .fetchTransactions(groupId!);
      }
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Group not found!")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.groupName),
        backgroundColor: Colors.teal,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              if (groupId != null) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupSettingsPage(
                      groupId: groupId!,
                      groupName: widget.groupName,
                      groupMembers: _groupMembers,
                      onLeaveGroup: (id) async {
                        await Provider.of<GroupProvider>(context, listen: false)
                            .leaveGroup(id, "YourUserName");

                        Navigator.pop(context);
                      },
                    ),
                  ),
                );

                if (result != null && result['action'] == 'leave') {
                  Navigator.pop(context);
                }
              }
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : Column(
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
                        "Members: ${_groupMembers.length}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                  const Spacer(),
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

          Expanded(
            child: groupId == null
                ? const Center(
              child: Text(
                "Group not found!",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('transactions')
                  .where('groupId', isEqualTo: groupId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
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
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: snapshot.data!.docs.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    var transaction = snapshot.data!.docs[index];

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
                          transaction['description'],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Paid by: ${transaction['paidBy']}",
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Text(
                          "\$${transaction['amount'].toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionDetailsPage(
                                transactionId: transaction.id, // Pass Firestore transaction ID
                                groupId: groupId!, // Ensure correct groupId is passed
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (groupId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddTransactionPage(groupName: widget.groupName),
              ),
            );
          }
        },
        backgroundColor: Colors.teal,
        elevation: 2,
        child: const Icon(Icons.add),
      ),
    );
  }
}
