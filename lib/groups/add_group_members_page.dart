import 'package:flutter/material.dart';

class AddGroupMembersPage extends StatefulWidget {
  final List<String> preselectedFriends;

  const AddGroupMembersPage({super.key, required this.preselectedFriends});

  @override
  _AddGroupMembersPageState createState() => _AddGroupMembersPageState();
}

class _AddGroupMembersPageState extends State<AddGroupMembersPage> {
  final List<String> friends = ['Vamshi', 'Karthik', 'Nandan', 'Moin'];
  late Set<String> selectedFriends;

  @override
  void initState() {
    super.initState();
    selectedFriends = widget.preselectedFriends.toSet();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Group Members"),
        backgroundColor: Colors.teal,
        elevation: 2, // Add subtle shadow
      ),
      body: Card( // Wrap the list in a Card
        elevation: 4,
        margin: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListView.separated( // Use ListView.separated for dividers
          itemCount: friends.length,
          separatorBuilder: (context, index) => const Divider(height: 1), // Add subtle dividers
          itemBuilder: (context, index) {
            final friend = friends[index];
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
              activeColor: Colors.teal, // Customize checkbox active color
              controlAffinity: ListTileControlAffinity.leading, // Checkbox on the left
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0), // Add padding
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        elevation: 4,
        onPressed: () {
          Navigator.pop(context, selectedFriends.toList());
        },
        child: const Icon(Icons.check),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}