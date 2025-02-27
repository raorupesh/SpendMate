import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spendmate/providers/chores_provider.dart';

class ChoreDetailsViewPage extends StatelessWidget {
  final ChorePlan plan;

  const ChoreDetailsViewPage({super.key, required this.plan});

  @override
  Widget build(BuildContext context) {
    final String currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chore Schedule"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Chore: ${plan.choreName}",
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal),
                    ),
                    const SizedBox(height: 10),
                    Text("Schedule for $currentMonth",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildChoreList(plan)),
          ],
        ),
      ),
    );
  }

  Widget _buildChoreList(ChorePlan plan) {
    List<Widget> taskWidgets = [];

    plan.directAssignments.forEach((person, tasks) {
      tasks.forEach((day, task) {
        if (task != "Not Assigned") {
          taskWidgets.add(
            Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: _getChoreIcon(task),
                title: Text(
                  "$person",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal),
                ),
                subtitle: Text(
                  "$task on $day",
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
            ),
          );
        }
      });
    });

    return taskWidgets.isNotEmpty
        ? ListView(children: taskWidgets)
        : const Center(
            child: Text(
              "No tasks assigned.",
              style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500),
            ),
          );
  }

  Icon _getChoreIcon(String task) {
    switch (task.toLowerCase()) {
      case "cooking":
        return const Icon(Icons.restaurant, color: Colors.teal, size: 24);
      case "laundry":
        return const Icon(Icons.local_laundry_service,
            color: Colors.teal, size: 24);
      case "trash":
        return const Icon(Icons.delete, color: Colors.teal, size: 24);
      case "cleaning":
        return const Icon(Icons.cleaning_services,
            color: Colors.teal, size: 24);
      case "dishes":
        return const Icon(Icons.local_dining, color: Colors.teal, size: 24);
      default:
        return const Icon(Icons.assignment, color: Colors.teal, size: 24);
    }
  }
}
