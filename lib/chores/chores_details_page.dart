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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate to Groups Page
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
      ),
      body: choreProvider.hasSchedule
          ? _buildScheduleView(choreProvider, currentMonth)
          : _buildEmptyView(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AssignChoresPage()),
          );
        },
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Widget _buildEmptyView() {
    return const Center(
      child: Text(
        "No chores assigned yet.\nTap + to create a schedule.",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 16, color: Colors.grey),
      ),
    );
  }

  Widget _buildScheduleView(ChoreProvider choreProvider, String currentMonth) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Chore: ${choreProvider.choreName}",
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
          ),
          const SizedBox(height: 10),
          Text("Schedule for $currentMonth",
              style: const TextStyle(fontSize: 18)),
          const Divider(),
          Expanded(child: _buildChoreList(choreProvider)),
        ],
      ),
    );
  }

  Widget _buildChoreList(ChoreProvider choreProvider) {
    List<Widget> dayWidgets = [];

    for (var day in choreProvider.daysOfWeek) {
      List<Widget> taskWidgets = [];

      choreProvider.finalSchedule.forEach((person, tasks) {
        if (tasks.containsKey(day) && tasks[day] != "Not Assigned") {
          taskWidgets.add(
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.task, color: Colors.teal, size: 18),
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

      if (taskWidgets.isNotEmpty) {
        // Show only days with assigned tasks
        dayWidgets.add(
          Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            elevation: 3,
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
                  const Divider(),
                  Column(children: taskWidgets),
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
            child: Text(
              "No tasks assigned.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          );
  }
}
