import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spendmate/groups/select_participants_page.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController expenseNameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  List<String> _groupMembers = [
    "Karthik",
    "Vamshi",
    "Moin",
    "Nandan"
  ]; // Example members
  Set<String> _selectedParticipants = {}; // ✅ Use Set to prevent duplicates

  bool isSaveEnabled = false;

  void validateFields() {
    setState(() {
      final isExpenseNameValid = expenseNameController.text.isNotEmpty;
      final isAmountValid = amountController.text.isNotEmpty &&
          RegExp(r'^\d+(\.\d{0,2})?$').hasMatch(amountController.text);
      isSaveEnabled = isExpenseNameValid && isAmountValid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Add Expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: expenseNameController,
              decoration: const InputDecoration(labelText: 'Expense Name'),
              onChanged: (_) => validateFields(),
            ),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))
              ],
              decoration: const InputDecoration(labelText: 'Amount'),
              onChanged: (_) => validateFields(),
            ),
            const SizedBox(height: 16),

            // ✅ Button to Select Participants (Opens new selection screen)
            ListTile(
              title: const Text("Participants"),
              subtitle: Text(_selectedParticipants.isNotEmpty
                  ? _selectedParticipants.join(", ")
                  : "Select participants"),
              trailing: const Icon(Icons.person_add),
              onTap: () async {
                final selected = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectParticipantsPage(
                      members: _groupMembers,
                      selectedParticipants: _selectedParticipants.toList(),
                    ),
                  ),
                );
                if (selected != null) {
                  setState(() {
                    _selectedParticipants =
                        Set.from(selected); //Prevents duplicates
                  });
                }
              },
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: isSaveEnabled
                  ? () {
                      // Logic to save expense
                      Navigator.pop(context);
                    }
                  : null,
              child: const Text("Save Expense"),
            ),
          ],
        ),
      ),
    );
  }
}
