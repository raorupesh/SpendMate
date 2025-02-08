import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:spendmate/groups/select_participants_page.dart';
import 'package:spendmate/transactions/split_method_page.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController expenseNameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();

  // Use the same list of friends from AddGroupMembersPage
  final List<String> _groupMembers = ['Vamshi', 'Karthik', 'Nandan', 'Moin'];
  Set<String> _selectedParticipants = {}; // Use Set to prevent duplicates

  bool isSaveEnabled = false;
  String? _splitMethod;
  Map<String, double> _participantShares = {};

  @override
  void initState() {
    super.initState();
  }

  void validateFields() {
    setState(() {
      final isExpenseNameValid = expenseNameController.text.isNotEmpty;
      final isAmountValid = amountController.text.isNotEmpty &&
          RegExp(r'^\d+(\.\d{0,2})?$').hasMatch(amountController.text);
      final isSplitMethodSelected = _splitMethod != null;
      isSaveEnabled = isExpenseNameValid && isAmountValid && isSplitMethodSelected;
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

            // Button to Select Participants (Opens new selection screen)
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
                        Set.from(selected); // Prevents duplicates
                    // Recalculate split with the selected participants
                    if (_splitMethod != null) {
                      _participantShares = _calculateSplit({"method": _splitMethod});
                    }
                  });
                }
              },
            ),

            const SizedBox(height: 16),
            ListTile(
              title: const Text("Split Method"),
              subtitle: Text(_splitMethod ?? "Select split method"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SplitMethodPage(
                      splitMethod: _splitMethod ?? "Equal",
                      onSave: (splitData) {
                        setState(() {
                          _splitMethod = splitData['method'];
                          _participantShares = _calculateSplit(splitData);
                          validateFields();
                        });
                      },
                    ),
                  ),
                );
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

  Map<String, double> _calculateSplit(Map<String, dynamic> splitData) {
    double totalAmount = double.tryParse(amountController.text) ?? 0.0;
    Map<String, double> shares = {};

    if (splitData['method'] == "Equal") {
      double splitAmount = totalAmount / _selectedParticipants.length;
      for (var participant in _selectedParticipants) {
        shares[participant] = splitAmount;
      }
    } else if (splitData['method'] == "Custom") {
      List<String> amounts = splitData['values'].split(',');
      for (int i = 0; i < _selectedParticipants.length; i++) {
        shares[_selectedParticipants.elementAt(i)] = double.parse(amounts[i]);
      }
    } else if (splitData['method'] == "Percentage") {
      List<String> percentages = splitData['values'].split(',');
      for (int i = 0; i < _selectedParticipants.length; i++) {
        shares[_selectedParticipants.elementAt(i)] =
            (double.parse(percentages[i]) / 100) * totalAmount;
      }
    }

    return shares;
  }
}