import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/providers/transaction_provider.dart';
import 'package:spendmate/groups/group_details_page.dart'; // ✅ Fix: Import this file
import 'package:spendmate/groups/add_group_members_page.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  void _showCreateGroupDialog() {
    TextEditingController groupNameController = TextEditingController();
    List<String> selectedFriends = [];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Create New Group"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: groupNameController,
                    textCapitalization: TextCapitalization.words, // ✅ Capitalize first letter of each word
                    decoration: const InputDecoration(hintText: "Enter group name"),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final friends = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddGroupMembersPage(preselectedFriends: selectedFriends),
                        ),
                      );
                      if (friends != null) {
                        setState(() {
                          selectedFriends = List<String>.from(friends);
                        });
                      }
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text("Add Members"),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    children: selectedFriends.map((friend) => Chip(label: Text(friend))).toList(),
                  ),
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: (selectedFriends.isEmpty || groupNameController.text.isEmpty)
                      ? null
                      : () {
                    Provider.of<GroupProvider>(context, listen: false).addGroup(
                      Group(
                        name: groupNameController.text,
                        members: selectedFriends,
                      ),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text("Create"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Groups"),
        backgroundColor: Colors.teal,
      ),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, child) {
          return ListView.builder(
            padding: const EdgeInsets.all(10),
            itemCount: groupProvider.groups.length,
            itemBuilder: (context, index) {
              final group = groupProvider.groups[index];
              return Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  title: Text(group.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: group.transactions.isEmpty
                      ? const Text("No transactions yet")
                      : Text(
                    group.balance < 0
                        ? "You owe \$${group.balance.abs().toStringAsFixed(2)}"
                        : "You are owed \$${group.balance.toStringAsFixed(2)}",
                    style: TextStyle(color: group.balance < 0 ? Colors.red : Colors.green),
                  ),

                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GroupDetailPage(groupName: group.name), // ✅ Now correctly defined
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _showCreateGroupDialog, // ✅ This correctly creates a group
        child: const Icon(Icons.add),
      ),
    );
  }
}
