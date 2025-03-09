import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:spendmate/models/chore_plan_model.dart';
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
                    const SizedBox(height: 8),
                    Text(
                      "Participants: ${plan.participants.join(", ")}",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w400),
                    ),
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
    final List<String> daysOfWeek = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"];

    // Sort task widgets by day of week for a more organized display
    for (String day in daysOfWeek) {
      List<Widget> dayTasks = [];

      plan.directAssignments.forEach((person, tasks) {
        if (tasks.containsKey(day) && tasks[day] != null && tasks[day] != "Not assigned") {
          String task = tasks[day]!;
          dayTasks.add(
            Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              child: ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: _getChoreIcon(task),
                ),
                title: Text(
                  person,
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          day,
                          style: const TextStyle(
                              fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                isThreeLine: true,
                trailing: _getAssignmentStatus(plan, person, day),
              ),
            ),
          );
        }
      });

      if (dayTasks.isNotEmpty) {
        // Add a day header with a more appealing design
        taskWidgets.add(
            Container(
              margin: const EdgeInsets.only(top: 16.0, bottom: 8.0),
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.teal, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    day,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
            )
        );

        // Add all tasks for this day
        taskWidgets.addAll(dayTasks);
      }
    }

    return taskWidgets.isNotEmpty
        ? ListView(children: taskWidgets)
        : Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.assignment_turned_in, size: 64, color: Colors.grey.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text(
            "No tasks assigned yet",
            style: TextStyle(
                color: Colors.grey,
                fontSize: 18,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text("Add Tasks"),
            onPressed: () {
              // Navigation or callback could be added here
            },
          )
        ],
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

  // Check if the person is available during this time based on the schedule data
  Widget _getAssignmentStatus(ChorePlan plan, String person, String day) {
    // Check if we have availability data in the final schedule
    if (plan.finalSchedule.containsKey("availableHours")) {
      var availableHours = plan.finalSchedule["availableHours"];
      if (availableHours != null &&
          availableHours[person] != null &&
          availableHours[person][day] != null &&
          availableHours[person][day].isNotEmpty) {
        // Person has specified availability for this day
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[300]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 14),
              const SizedBox(width: 4),
              Text(
                "Available ${availableHours[person][day]}",
                style: TextStyle(fontSize: 12, color: Colors.green[800]),
              ),
            ],
          ),
        );
      }
    }

    // Check if we have busy hours data
    if (plan.finalSchedule.containsKey("busyHours")) {
      var busyHours = plan.finalSchedule["busyHours"];
      if (busyHours != null &&
          busyHours[person] != null &&
          busyHours[person][day] != null &&
          busyHours[person][day].isNotEmpty) {
        // Person has specified busy hours for this day
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red[300]!),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.access_time, color: Colors.red, size: 14),
              const SizedBox(width: 4),
              Text(
                "Busy ${busyHours[person][day]}",
                style: TextStyle(fontSize: 12, color: Colors.red[800]),
              ),
            ],
          ),
        );
      }
    }

    // Default case - no specific scheduling info (improved from original blue chip)
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.teal[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.teal[300]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.assignment_turned_in, color: Colors.teal, size: 14),
          const SizedBox(width: 4),
          Text(
            "Assigned",
            style: TextStyle(fontSize: 12, color: Colors.teal[800]),
          ),
        ],
      ),
    );
  }
}