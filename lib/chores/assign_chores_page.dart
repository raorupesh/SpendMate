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
  final TextEditingController _participantNameController = TextEditingController();

  String _selectedAssignmentType = "Manual Task";

  final List<String> participants = [];
  final List<String> daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];
  final List<String> tasks = ["Cleaning", "Dishes", "Cooking", "Laundry", "Trash", "Other"];

  Map<String, Map<String, String>> directAssignments = {};
  Map<String, Map<String, String>> availableHours = {};
  Map<String, Map<String, String>> busyHours = {};
  Map<String, bool> expandedState = {}; // Track expanded state for each participant

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assign Weekly Chores"),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _choreNameController,
              decoration: const InputDecoration(labelText: "Chore Name"),
            ),
            const SizedBox(height: 16),

            // Assignment Type Dropdown
            DropdownButton<String>(
              value: _selectedAssignmentType,
              items: ["Manual Task", "Available Time", "Busy Time"].map((option) {
                return DropdownMenuItem(value: option, child: Text(option));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedAssignmentType = value!;
                });
              },
            ),
            const SizedBox(height: 16),

            // Add Participant Field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _participantNameController,
                    decoration: const InputDecoration(hintText: "Enter participant name"),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () {
                    if (_participantNameController.text.isNotEmpty) {
                      setState(() {
                        String participant = _participantNameController.text;
                        participants.add(participant);
                        directAssignments[participant] = {};
                        availableHours[participant] = {};
                        busyHours[participant] = {};
                        expandedState[participant] = false;
                        _participantNameController.clear();
                      });
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // **Dynamic Participant Tiles**
            Column(
              children: participants.map((person) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  child: Column(
                    children: [
                      ListTile(
                        title: Text(person, style: const TextStyle(fontWeight: FontWeight.bold)),
                        trailing: Icon(expandedState[person]! ? Icons.expand_less : Icons.expand_more),
                        onTap: () {
                          setState(() {
                            expandedState[person] = !expandedState[person]!;
                          });
                        },
                      ),
                      if (expandedState[person]!) _buildTaskFields(person),
                    ],
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // **Save Button**
            Center(
              child: ElevatedButton(
                onPressed: () {
                  final choreProvider = Provider.of<ChoreProvider>(context, listen: false);
                  final newChorePlan = ChorePlan(
                    choreName: _choreNameController.text,
                    participants: List.from(participants),
                    directAssignments: Map.from(directAssignments),
                    finalSchedule: {
                      ...availableHours, // Save available times
                      ...busyHours, // Save busy times
                    },
                  );

                  choreProvider.addChorePlan(newChorePlan);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Chore Plan Saved Successfully!")),
                  );

                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const ChoresDetailsPage()),
                  );
                },
                child: const Text("Save Chore Plan"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskFields(String person) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedAssignmentType == "Manual Task") _buildManualTaskFields(person),
        if (_selectedAssignmentType == "Available Time") _buildAvailableTimeFields(person),
        if (_selectedAssignmentType == "Busy Time") _buildBusyTimeFields(person),
      ],
    );
  }

  Widget _buildAvailableTimeFields(String person) {
    return Column(
      children: daysOfWeek.map((day) {
        return ListTile(
          title: Text(day),
          subtitle: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: "Start Time"),
                  onChanged: (value) {
                    setState(() {
                      availableHours[person]?[day] = "${value} - ${availableHours[person]?[day]?.split(' - ')[1] ?? ''}";
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: "End Time"),
                  onChanged: (value) {
                    setState(() {
                      availableHours[person]?[day] = "${availableHours[person]?[day]?.split(' - ')[0] ?? ''} - $value";
                    });
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBusyTimeFields(String person) {
    return Column(
      children: daysOfWeek.map((day) {
        return ListTile(
          title: Text(day),
          subtitle: Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: "Start Time"),
                  onChanged: (value) {
                    setState(() {
                      busyHours[person]?[day] = "${value} - ${busyHours[person]?[day]?.split(' - ')[1] ?? ''}";
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  decoration: const InputDecoration(labelText: "End Time"),
                  onChanged: (value) {
                    setState(() {
                      busyHours[person]?[day] = "${busyHours[person]?[day]?.split(' - ')[0] ?? ''} - $value";
                    });
                  },
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
  Widget _buildManualTaskFields(String person) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: daysOfWeek.map((day) {
        return ListTile(
          title: Text(day),
          trailing: DropdownButton<String>(
            hint: const Text("Assign Task"),
            value: directAssignments[person]?[day], // Retrieve assigned task
            items: tasks.map((task) {
              return DropdownMenuItem(value: task, child: Text(task));
            }).toList(),
            onChanged: (task) {
              setState(() {
                if (task != null) {
                  directAssignments[person] ??= {}; // Initialize if null
                  directAssignments[person]![day] = task;
                }
              });
            },
          ),
        );
      }).toList(),
    );
  }

}
