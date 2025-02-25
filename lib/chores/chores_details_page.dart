import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/chores/assign_chores_page.dart';
import 'package:spendmate/providers/chores_provider.dart';

class ChoresDetailsPage extends StatelessWidget {
  const ChoresDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final choreProvider = Provider.of<ChoreProvider>(context);
    final String currentMonth = DateFormat('MMMM yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Chores Schedule"),
        backgroundColor: Colors.teal,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade50, Colors.teal.shade100],
            // Soft gradient background
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: choreProvider.finalSchedule.isNotEmpty
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Schedule for $currentMonth",
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal),
                    ),
                    const SizedBox(height: 10),
                    Expanded(child: _buildFormattedSchedule(choreProvider)),
                  ],
                ),
              )
            : const Center(
                child: Text(
                  "No schedule generated for this month.",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey),
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AssignChoresPage()),
          );
        },
        child: const Icon(Icons.add, size: 28), // "+" icon with larger size
      ),
    );
  }

  Widget _buildFormattedSchedule(ChoreProvider choreProvider) {
    List<Widget> dayWidgets = [];

    for (var day in choreProvider.daysOfWeek) {
      List<Widget> personTasks = [];

      choreProvider.finalSchedule.forEach((person, tasks) {
        if (tasks[day] != null && tasks[day] != "Not Assigned") {
          personTasks.add(
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 4, bottom: 4),
              child: Row(
                children: [
                  _getTaskIcon(tasks[day]!), // Task-specific icon
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "$person: ${tasks[day]}",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      });

      if (personTasks.isNotEmpty) {
        dayWidgets.add(
          Card(
            elevation: 4, // Adds a nice shadow effect
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day,
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.teal),
                  ),
                  const Divider(), // A separator for better clarity
                  Column(children: personTasks),
                ],
              ),
            ),
          ),
        );
      }
    }

    return dayWidgets.isNotEmpty
        ? ListView(children: dayWidgets)
        : const Center(
            child: Text("No tasks assigned.",
                style: TextStyle(color: Colors.grey, fontSize: 16)),
          );
  }

  /// Returns an icon based on the assigned task
  Widget _getTaskIcon(String task) {
    Map<String, IconData> taskIcons = {
      "Cleaning": Icons.cleaning_services,
      "Cooking": Icons.restaurant,
      "Dishes": Icons.local_dining,
      "Laundry": Icons.local_laundry_service,
      "Trash": Icons.delete,
      "Other": Icons.assignment
    };

    return Icon(taskIcons[task] ?? Icons.task, color: Colors.teal, size: 22);
  }
}
