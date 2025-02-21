import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/chores/assign_chores_page.dart';
import 'package:spendmate/providers/chores_provider.dart';

class ChoresPage extends StatelessWidget {
  const ChoresPage({super.key});

  @override
  Widget build(BuildContext context) {
    final choreProvider = Provider.of<ChoreProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Weekly Chores Schedule"),
        backgroundColor: Colors.teal,
      ),
      body: choreProvider.finalSchedule.isNotEmpty
          ? _buildWeeklySchedule(choreProvider)
          : const Center(child: Text("No schedule generated. Click + to assign chores.")),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const AssignChoresPage()));
        },
        child: const Icon(Icons.add),
        backgroundColor: Colors.teal,
      ),
    );
  }

  Widget _buildWeeklySchedule(ChoreProvider choreProvider) {
    return ListView(
      children: choreProvider.finalSchedule.entries.map((entry) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.key, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...choreProvider.daysOfWeek.map((day) {
              return ListTile(
                title: Text(day),
                trailing: Text(entry.value[day] ?? "No Task"),
              );
            }).toList(),
          ],
        );
      }).toList(),
    );
  }
}
