import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/chores/chores_details_page.dart';
import 'package:spendmate/providers/chores_provider.dart';

class AssignChoresPage extends StatefulWidget {
  const AssignChoresPage({super.key});

  @override
  _AssignChoresPageState createState() => _AssignChoresPageState();
}

class _AssignChoresPageState extends State<AssignChoresPage> {
  final TextEditingController _choreNameController = TextEditingController();
  final TextEditingController _participantNameController =
      TextEditingController();
  final List<String> participants = [];
  final List<String> daysOfWeek = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];
  final List<String> tasks = [
    "Cleaning",
    "Dishes",
    "Cooking",
    "Laundry",
    "Trash",
    "Other"
  ];
  Map<String, Map<String, String>> directAssignments = {};

  @override
  Widget build(BuildContext context) {
    final choreProvider = Provider.of<ChoreProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Assign Weekly Chores"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Chore Name Input
            TextField(
              controller: _choreNameController,
              decoration: const InputDecoration(labelText: "Chore Name"),
              onChanged: (value) => choreProvider.setChoreName(value),
            ),
            const SizedBox(height: 16),

            // Add Participants Section
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _participantNameController,
                    decoration: const InputDecoration(
                        hintText: "Enter participant name"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_participantNameController.text.isNotEmpty) {
                      setState(() {
                        participants.add(_participantNameController.text);
                        directAssignments[_participantNameController.text] = {};
                        _participantNameController.clear();
                      });
                      choreProvider.setParticipants(participants);
                    }
                  },
                ),
              ],
            ),

            // Display Participants
            if (participants.isNotEmpty) ...[
              Wrap(
                spacing: 8.0,
                children: participants
                    .map((name) => Chip(label: Text(name)))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Show warning if less than 2 participants
            if (participants.length < 2)
              const Text(
                "At least 2 participants are required.",
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),

            // Assign Chores
            if (participants.length >= 2) ...[
              Expanded(child: _buildDirectAssignTable()),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (directAssignments.values
                        .any((dayMap) => dayMap.isEmpty)) {
                      setState(() {
                        choreProvider.showError = true;
                      });
                    } else {
                      choreProvider.setDirectAssignments(directAssignments);
                      choreProvider.generateSchedule();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ChoresDetailsPage()),
                      );
                    }
                  },
                  child: const Text("Generate Schedule"),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDirectAssignTable() {
    return ListView.builder(
      itemCount: participants.length,
      itemBuilder: (context, index) {
        String person = participants[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ExpansionTile(
            title: Text(person,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            children: daysOfWeek.map((day) {
              return ListTile(
                title: Text(day),
                trailing: DropdownButton<String>(
                  hint: const Text("Assign Task"),
                  value: directAssignments[person]?[day],
                  items: tasks.map((task) {
                    return DropdownMenuItem(value: task, child: Text(task));
                  }).toList(),
                  onChanged: (task) {
                    setState(() {
                      if (task != null) {
                        directAssignments[person]![day] = task;
                      }
                    });
                  },
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }
}
