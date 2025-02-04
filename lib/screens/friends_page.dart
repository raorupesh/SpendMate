// FriendsPage.dart
import 'package:flutter/material.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final List<String> friends = ['Vamshi', 'Karthik', 'Nandan', 'Moin'];
  final Set<String> selectedFriends = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Friends to Add"),
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
        onPressed: () {
          // Save selected friends to the group and return to AddTransactionPage
          Navigator.pop(context, selectedFriends.toList());
        },
        child: const Icon(Icons.check),
        backgroundColor: Colors.teal,
      ),
    );
  }
}
