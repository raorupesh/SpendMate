import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/chores/assign_chores_page.dart';
import 'package:spendmate/chores/chores_details_view_page.dart';
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
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
      ),
      body: choreProvider.chorePlans.isNotEmpty
          ? ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: choreProvider.chorePlans.length,
              itemBuilder: (context, index) {
                final plan = choreProvider.chorePlans.reversed
                    .toList()[index]; // Show recent first
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  elevation: 3,
                  child: ListTile(
                    title: Text(plan.choreName,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal)),
                    subtitle:
                        Text("Participants: ${plan.participants.join(', ')}"),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteConfirmationDialog(
                            context, choreProvider, index);
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ChoreDetailsViewPage(plan: plan),
                        ),
                      );
                    },
                  ),
                );
              },
            )
          : const Center(
              child: Text(
                "No chores assigned yet. Tap + to create a schedule.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
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
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, ChoreProvider choreProvider, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Chore Plan"),
          content:
              const Text("Are you sure you want to delete this chore plan?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                choreProvider.removeChorePlan(index);
                Navigator.pop(context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
