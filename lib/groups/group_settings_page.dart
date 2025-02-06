import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/providers/transaction_provider.dart';

class GroupSettingsPage extends StatelessWidget {
  final String groupName;

  const GroupSettingsPage({super.key, required this.groupName});

  @override
  Widget build(BuildContext context) {
    final group = Provider.of<GroupProvider>(context).getGroup(groupName);

    return Scaffold(
      appBar: AppBar(
        title: Text("Group Settings"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Group Members",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: group.transactions.isNotEmpty
                    ? group.transactions[0].participants.length
                    : 0,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.person),
                    title: Text(group.transactions[0].participants[index]),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                ),
                onPressed: () {
                  _showLeaveGroupDialog(context);
                },
                child: const Text("Leave Group"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaveGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Leave Group"),
          content: const Text("Are you sure you want to leave this group?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Provider.of<GroupProvider>(context, listen: false).leaveGroup(groupName);
                Navigator.popUntil(context, (route) => route.isFirst); // Navigate back to Groups list
              },
              child: const Text("Leave", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

}
