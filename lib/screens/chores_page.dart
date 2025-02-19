import 'package:flutter/material.dart';

class ChoresPage extends StatefulWidget {
  const ChoresPage({super.key});

  @override
  _ChoresPageState createState() => _ChoresPageState();
}

class _ChoresPageState extends State<ChoresPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chores"),
        backgroundColor: Colors.teal,
      ),
      body: const Center(
        child: Text(
          "Chores Page Coming Soon...",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
