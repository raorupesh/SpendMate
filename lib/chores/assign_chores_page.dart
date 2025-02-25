import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/providers/chores_provider.dart';

class AssignChoresPage extends StatefulWidget {
  const AssignChoresPage({super.key});

  @override
  _AssignChoresPageState createState() => _AssignChoresPageState();
}

class _AssignChoresPageState extends State<AssignChoresPage> {
  final TextEditingController _participantCountController =
  TextEditingController();
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
            TextField(
              controller: _participantCountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Number of People"),
              onChanged: (value) {
                int count = int.tryParse(value) ?? 0;
                if (count > 1) {
                  choreProvider.setParticipantCount(count);
                  setState(() {
                    directAssignments = {
                      for (var person in choreProvider.participants) person: {}
                    };
                  });
                } else {
                  choreProvider.setParticipantCount(0);
                  setState(() {
                    directAssignments.clear();
                  });
                }
              },
            ),
            if (choreProvider.participants.length <= 1)
              const Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "At least 2 participants are required.",
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            const SizedBox(height: 16),
            if (choreProvider.participants.length > 1) ...[
              DropdownButton<String>(
                isExpanded: true,
                value: choreProvider.assignmentMethod.isNotEmpty
                    ? choreProvider.assignmentMethod
                    : null,
                hint: const Text("Select Assignment Method"),
                items: ["Enter Free Time", "Direct Assign"]
                    .map((method) =>
                    DropdownMenuItem(value: method, child: Text(method)))
                    .toList(),
                onChanged: (method) {
                  if (method != null) {
                    choreProvider.setAssignmentMethod(method);
                    setState(() {});
                  }
                },
              ),
              const SizedBox(height: 16),
              if (choreProvider.assignmentMethod == "Direct Assign")
                Expanded(child: _buildDirectAssignTable(choreProvider)),
              if (choreProvider.showError)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    "Please assign tasks for all days before generating the schedule.",
                    style: const TextStyle(
                        color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
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
                      Navigator.pop(context);
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

  Widget _buildDirectAssignTable(ChoreProvider choreProvider) {
    return ListView.builder(
      itemCount: choreProvider.participants.length,
      itemBuilder: (context, index) {
        String person = choreProvider.participants[index];

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: ExpansionTile(
            title: Text(person,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            children: daysOfWeek.map((day) {
              return ListTile(
                title: Text(day),
                trailing: DropdownButton<String>(
                  hint: const Text("Assign Task"),
                  value: directAssignments[person]?[day],
                  items: tasks.map((task) {
                    return DropdownMenuItem(
                      value: task,
                      child: Text(task),
                    );
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
