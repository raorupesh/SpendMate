// split_method_page.dart
import 'package:flutter/material.dart';

class SplitMethodPage extends StatelessWidget {
  final String splitMethod;
  final ValueChanged<String> onSave;

  const SplitMethodPage({super.key, required this.splitMethod, required this.onSave});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Split Method"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.cancel),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text("Equal Split"),
            onTap: () {
              onSave("Equal");
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text("Custom Split"),
            onTap: () {
              // Navigate to custom split page
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text("Percentage Split"),
            onTap: () {
              // Navigate to percentage split page
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
