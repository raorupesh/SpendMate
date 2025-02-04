import 'package:flutter/material.dart';
import 'home_page.dart';

class GroupsPage extends StatefulWidget {
  const GroupsPage({super.key});

  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  // Temporary sample groups
  List<Map<String, dynamic>> groups = [
    {"name": "Friends Trip", "balance": -50.00},
    {"name": "Family Expenses", "balance": 120.00},
    {"name": "Roommates", "balance": -30.50},
  ];

  // Method to show the create group dialog
  void _showCreateGroupDialog() {
    TextEditingController groupNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Create New Group"),
          content: TextField(
            controller: groupNameController,
            decoration: const InputDecoration(hintText: "Enter group name"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (groupNameController.text.isNotEmpty) {
                  setState(() {
                    groups.add({"name": groupNameController.text, "balance": 0.0});
                  });
                  Navigator.pop(context);
                }
              },
              child: const Text("Create"),
            ),
          ],
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');// Pop GroupsPage to navigate back to BottomNavBar
          },
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(10),
        itemCount: groups.length,
        itemBuilder: (context, index) {
          final group = groups[index];
          return Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(group['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                group['balance'] < 0
                    ? "You owe \$${group['balance'].abs().toStringAsFixed(2)}"
                    : "You are owed \$${group['balance'].toStringAsFixed(2)}",
                style: TextStyle(color: group['balance'] < 0 ? Colors.red : Colors.green),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Navigate to group details (to be implemented later)
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _showCreateGroupDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
