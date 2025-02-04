import 'package:flutter/material.dart';

class ChoresPage extends StatelessWidget {
  const ChoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chores"),
        backgroundColor: Colors.teal,
      ),
      body: Center(
        child: const Text(
          "Here you can manage your chores.",
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
