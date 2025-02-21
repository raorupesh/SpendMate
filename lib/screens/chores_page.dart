import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/providers/chores_provider.dart';

class ChoresPage extends StatelessWidget {
  const ChoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChoreProvider(),
      child: const ChoresScreen(),
    );
  }
}

class ChoresScreen extends StatelessWidget {
  const ChoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final choreProvider = Provider.of<ChoreProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chores Management"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Number of participants input
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Number of People"),
              onChanged: (value) {
                int count = int.tryParse(value) ?? 0;
                if (count > 0) choreProvider.setParticipantCount(count);
              },
            ),
            const SizedBox(height: 16),

            // Assignment Method Dropdown
            DropdownButton<String>(
              isExpanded: true,
              value: choreProvider.assignmentMethod.isNotEmpty ? choreProvider.assignmentMethod : null,
              hint: const Text("Select Assignment Method"),
              items: ["Enter Free Time", "Direct Assign"]
                  .map((method) => DropdownMenuItem(value: method, child: Text(method)))
                  .toList(),
              onChanged: (method) {
                if (method != null) choreProvider.setAssignmentMethod(method);
              },
            ),
            const SizedBox(height: 16),

            // Free Time Table
            if (choreProvider.assignmentMethod == "Enter Free Time")
              Expanded(child: _buildFreeTimeTable(choreProvider)),

            // Direct Assign Table
            if (choreProvider.assignmentMethod == "Direct Assign")
              Expanded(child: _buildDirectAssignTable(context, choreProvider)),

            // Error Message if fields are incomplete
            if (choreProvider.showError)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  "Please fill in all the details before generating the schedule.",
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),

            // Generate Schedule Button
            if (choreProvider.showGenerateButton)
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (choreProvider.validateInputs()) {
                      choreProvider.generateSchedule();
                    }
                  },
                  child: const Text("Generate Schedule"),
                ),
              ),

            // Display the final schedule
            if (choreProvider.finalSchedule.isNotEmpty)
              Expanded(child: _buildFinalScheduleTable(choreProvider)),
          ],
        ),
      ),
    );
  }

  // Free Time Table Widget
  Widget _buildFreeTimeTable(ChoreProvider choreProvider) {
    return ListView(
      children: choreProvider.participants.map((person) {
        return ListTile(
          title: Text(person),
          trailing: DropdownButton<String>(
            hint: const Text("Select Free Time"),
            value: choreProvider.freeTime[person],
            items: ["Morning", "Afternoon", "Evening", "Night"]
                .map((time) => DropdownMenuItem(value: time, child: Text(time)))
                .toList(),
            onChanged: (time) {
              if (time != null) choreProvider.setFreeTime(person, time);
            },
          ),
        );
      }).toList(),
    );
  }

  // Direct Assign Table Widget
  Widget _buildDirectAssignTable(BuildContext context, ChoreProvider choreProvider) {
    return ListView(
      children: choreProvider.participants.map((person) {
        TextEditingController customTaskController = TextEditingController();
        return ListTile(
          title: Text(person),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButton<String>(
                hint: const Text("Assign Task"),
                value: choreProvider.assignedTasks[person],
                items: ["Cleaning", "Dishes", "Cooking", "Laundry", "Trash", "Other"]
                    .map((task) => DropdownMenuItem(value: task, child: Text(task)))
                    .toList(),
                onChanged: (task) {
                  if (task != null) choreProvider.assignTaskDirectly(person, task);
                },
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.add, color: Colors.teal),
                onPressed: () {
                  _showCustomTaskDialog(context, choreProvider, person, customTaskController);
                },
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // Custom Task Input Dialog
  void _showCustomTaskDialog(BuildContext context, ChoreProvider choreProvider, String person, TextEditingController controller) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Custom Task"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter custom task"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  choreProvider.assignTaskDirectly(person, controller.text);
                  Navigator.pop(context);
                }
              },
              child: const Text("Add Task"),
            ),
          ],
        );
      },
    );
  }

  // Final Schedule Table
  Widget _buildFinalScheduleTable(ChoreProvider choreProvider) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(top: 16),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            const Text(
              "Final Schedule",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Table(
              border: TableBorder.all(),
              children: [
                const TableRow(
                  decoration: BoxDecoration(color: Colors.teal),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Person", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("Assigned Task", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                ...choreProvider.finalSchedule.entries.map(
                      (entry) => TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(entry.key),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(entry.value),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
