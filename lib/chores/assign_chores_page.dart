import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/providers/chores_provider.dart';

class AssignChoresPage extends StatelessWidget {
  const AssignChoresPage({super.key});

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
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Number of People"),
              onChanged: (value) {
                int count = int.tryParse(value) ?? 0;
                if (count > 0) choreProvider.setParticipantCount(count);
              },
            ),
            const SizedBox(height: 16),

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

            if (choreProvider.assignmentMethod == "Enter Free Time")
              Expanded(child: _buildFreeTimeTable(choreProvider)),

            if (choreProvider.assignmentMethod == "Direct Assign")
              Expanded(child: _buildDirectAssignTable(context, choreProvider)),

            if (choreProvider.showError)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  "Please fill in all details before generating the schedule.",
                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),

            Center(
              child: ElevatedButton(
                onPressed: () {
                  if (choreProvider.validateInputs()) {
                    choreProvider.generateSchedule();
                    Navigator.pop(context);
                  }
                },
                child: const Text("Generate Schedule"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFreeTimeTable(ChoreProvider choreProvider) {
    return ListView(
      children: choreProvider.participants.expand((person) {
        return choreProvider.daysOfWeek.map((day) {
          return ListTile(
            title: Text("$person - $day"),
            trailing: DropdownButton<String>(
              hint: const Text("Select Free Time"),
              value: choreProvider.freeTime[person]![day],
              items: ["Morning", "Afternoon", "Evening", "Night"]
                  .map((time) => DropdownMenuItem(value: time, child: Text(time)))
                  .toList(),
              onChanged: (time) {
                if (time != null) choreProvider.setFreeTime(person, day, time);
              },
            ),
          );
        }).toList();
      }).toList(),
    );
  }

  Widget _buildDirectAssignTable(BuildContext context, ChoreProvider choreProvider) {
    return ListView(
      children: choreProvider.participants.expand((person) {
        return choreProvider.daysOfWeek.map((day) {
          return ListTile(
            title: Text("$person - $day"),
            trailing: DropdownButton<String>(
              hint: const Text("Assign Task"),
              value: choreProvider.assignedTasks[person]![day],
              items: ["Cleaning", "Dishes", "Cooking", "Laundry", "Trash", "Other"]
                  .map((task) => DropdownMenuItem(value: task, child: Text(task)))
                  .toList(),
              onChanged: (task) {
                if (task != null) choreProvider.assignTaskDirectly(person, day, task);
              },
            ),
          );
        }).toList();
      }).toList(),
    );
  }
}
