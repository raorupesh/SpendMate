import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/chores/assign_chores_page.dart';
import 'package:spendmate/chores/chores_details_view_page.dart';
import 'package:spendmate/models/chore_plan_model.dart';
import 'package:spendmate/providers/chores_provider.dart';

class ChoresDetailsPage extends StatelessWidget {
  const ChoresDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chore Plans"),
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false,
      ),
      body: Consumer<ChoreProvider>(
        builder: (context, choreProvider, child) {
          if (choreProvider.chorePlans.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.assignment_late, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    "No chore plans available",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: choreProvider.chorePlans.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final plan = choreProvider.chorePlans[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChoreDetailsViewPage(plan: plan),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                plan.choreName,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.red),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text("Delete Chore Plan"),
                                    content: const Text("Are you sure you want to delete this chore plan?"),
                                    actions: [
                                      TextButton(
                                        child: const Text("Cancel"),
                                        onPressed: () => Navigator.pop(context),
                                      ),
                                      TextButton(
                                        child: const Text("Delete", style: TextStyle(color: Colors.red)),
                                        onPressed: () {
                                          choreProvider.deleteChorePlan(plan.id); // Use plan.id instead of index
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Participants: ${plan.participants.join(", ")}",
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildSummaryChip(
                              "${_countAssignedTasks(plan)} Tasks",
                              Icons.assignment_turned_in,
                              Colors.blue,
                            ),
                            const SizedBox(width: 8),
                            _buildSummaryChip(
                              "${plan.participants.length} People",
                              Icons.people,
                              Colors.green,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              icon: const Icon(Icons.visibility, size: 20),
                              label: const Text("View Details"),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChoreDetailsViewPage(plan: plan),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );

        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AssignChoresPage()),
          );
        },
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSummaryChip(String label, IconData icon, Color color) {
    return Chip(
      avatar: Icon(icon, size: 16, color: color),
      label: Text(label),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color, fontWeight: FontWeight.w500),
    );
  }

  int _countAssignedTasks(ChorePlan plan) {
    int count = 0;
    plan.directAssignments.forEach((person, tasks) {
      tasks.forEach((day, task) {
        if (task != null && task.isNotEmpty && task != "Not assigned") {
          count++;
        }
      });
    });
    return count;
  }
}