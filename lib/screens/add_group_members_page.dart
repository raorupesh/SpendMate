import 'package:flutter/material.dart';

class AddGroupMembersPage extends StatefulWidget {
  const AddGroupMembersPage({super.key});

  @override
  _AddGroupMembersPageState createState() => _AddGroupMembersPageState();
}

class _AddGroupMembersPageState extends State<AddGroupMembersPage> {
  final List<String> friends = ["bhAAi", "Moin Beta", "Nandan", "Karthik", "Vamshi"];
  final Set<String> selectedFriends = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Group Members"),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: friends.map((friend) {
          return CheckboxListTile(
            title: Text(friend),
            value: selectedFriends.contains(friend),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  selectedFriends.add(friend);
                } else {
                  selectedFriends.remove(friend);
                }
              });
            },
          );
        }).toList(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.pop(context, selectedFriends.toList());
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
