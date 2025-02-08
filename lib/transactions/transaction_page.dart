import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/providers/transaction_provider.dart';
import 'package:spendmate/transactions/split_method_page.dart';
import 'package:spendmate/groups/select_participants_page.dart';

class AddTransactionPage extends StatefulWidget {
  final String groupName;

  const AddTransactionPage({super.key, required this.groupName});

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _transactionDate = DateTime.now();
  String? _splitMethod;
  Set<String> _selectedParticipants = {};
  Map<String, double> _participantShares = {};
  bool isSaveEnabled = false;

  @override
  Widget build(BuildContext context) {
    final group = Provider.of<GroupProvider>(context).getGroup(widget.groupName);
    List<String> groupMembers = group.members;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Transaction"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'Transaction Description'),
              onChanged: (_) => validateFields(),
            ),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                      members: groupMembers,
                      selectedParticipants: _selectedParticipants.toList(),
                    ),
                  ),
                );
                if (selected != null) {
                  setState(() {
                    _selectedParticipants = Set.from(selected); // Prevents duplicates
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
                        try {
                          setState(() {
                            _splitMethod = splitData['method'];
                            _participantShares = _calculateSplit(splitData);
                            validateFields();
                          });
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(e.toString())),
                          );
                        }
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
                final amount = double.tryParse(_amountController.text);
                if (amount != null && _descriptionController.text.isNotEmpty) {
                  try {
                    final transaction = Transaction(
                      description: _descriptionController.text.trim(),
                      amount: amount,
                      date: _transactionDate,
                      participantShares: _participantShares,
                    );
                    Provider.of<GroupProvider>(context, listen: false)
                        .addTransaction(widget.groupName, transaction);
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString())),
                    );
                  }
                }
              }
                  : null,
              child: const Text("Save Transaction"),
            ),
          ],
        ),
      ),
    );
  }

  void validateFields() {
    setState(() {
      final isDescriptionValid = _descriptionController.text.isNotEmpty;
      final isAmountValid = _amountController.text.isNotEmpty &&
          RegExp(r'^\d+(\.\d{0,2})?$').hasMatch(_amountController.text);
      final isSplitMethodSelected = _splitMethod != null;
      isSaveEnabled = isDescriptionValid && isAmountValid && isSplitMethodSelected;
    });
  }

  Map<String, double> _calculateSplit(Map<String, dynamic> splitData) {
    double totalAmount = double.tryParse(_amountController.text) ?? 0.0;
    Map<String, double> shares = {};

    if (splitData['method'] == "Equal") {
      double splitAmount = totalAmount / _selectedParticipants.length;
      for (var participant in _selectedParticipants) {
        shares[participant] = splitAmount;
      }
    } else if (splitData['method'] == "Custom") {
      List<String> amounts = splitData['values'].split(',');
      double totalCustomAmount = 0.0;
      for (int i = 0; i < _selectedParticipants.length; i++) {
        double amount = double.parse(amounts[i]);
        shares[_selectedParticipants.elementAt(i)] = amount;
        totalCustomAmount += amount;
      }
      if (totalCustomAmount != totalAmount) {
        throw Exception("Custom amounts do not add up to the total amount.");
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