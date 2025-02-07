import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/providers/transaction_provider.dart';
import 'package:spendmate/transactions/split_method_page.dart';

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
  String _splitMethod = "Equal";
  String _payer = 'You';
  List<String> _selectedFriends = [];
  Map<String, double> _participantShares = {};

  @override
  Widget build(BuildContext context) {
    final group =
        Provider.of<GroupProvider>(context).getGroup(widget.groupName);
    List<String> groupMembers = group.members; // Get members of the group

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
              decoration:
                  const InputDecoration(labelText: 'Transaction Description'),
            ),
            TextField(
              controller: _amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 16),

            //Button to Select Participants
            ListTile(
              title: const Text("Participants"),
              subtitle: Text(_selectedFriends.isNotEmpty
                  ? _selectedFriends.join(", ")
                  : "Select participants"),
              trailing: const Icon(Icons.person_add),
              onTap: () async {
                List<String>? selectedParticipants =
                    await _selectParticipantsDialog(groupMembers);
                if (selectedParticipants != null) {
                  setState(() {
                    _selectedFriends = selectedParticipants;
                  });
                }
              },
            ),

            const SizedBox(height: 16),
            ListTile(
              title: const Text("Split Method"),
              subtitle: Text(_splitMethod),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SplitMethodPage(
                      splitMethod: _splitMethod,
                      onSave: (splitData) {
                        setState(() {
                          _splitMethod = splitData['method'];
                          _participantShares = _calculateSplit(splitData);
                        });
                      },
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text);
                if (amount != null && _descriptionController.text.isNotEmpty) {
                  final transaction = Transaction(
                    description: _descriptionController.text.trim(),
                    amount: amount,
                    date: _transactionDate,
                    participantShares: _participantShares,
                  );
                  Provider.of<GroupProvider>(context, listen: false)
                      .addTransaction(widget.groupName, transaction);
                  Navigator.pop(context);
                }
              },
              child: const Text("Save Transaction"),
            ),
          ],
        ),
      ),
    );
  }

  /// **Dialog to Select Participants**
  Future<List<String>?> _selectParticipantsDialog(List<String> members) async {
    List<String> tempSelected = List.from(_selectedFriends);
    return await showDialog<List<String>>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Select Participants"),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: members.map((member) {
                return CheckboxListTile(
                  title: Text(member),
                  value: tempSelected.contains(member),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        tempSelected.add(member);
                      } else {
                        tempSelected.remove(member);
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null), // Cancel
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, tempSelected),
              child: const Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  Map<String, double> _calculateSplit(Map<String, dynamic> splitData) {
    double totalAmount = double.tryParse(_amountController.text) ?? 0.0;
    Map<String, double> shares = {};

    if (splitData['method'] == "Equal") {
      double splitAmount = totalAmount / (_selectedFriends.length + 1);
      shares[_payer] = splitAmount;
      for (var friend in _selectedFriends) {
        shares[friend] = splitAmount;
      }
    } else if (splitData['method'] == "Custom") {
      List<String> amounts = splitData['values'].split(',');
      for (int i = 0; i < _selectedFriends.length; i++) {
        shares[_selectedFriends[i]] = double.parse(amounts[i]);
      }
    } else if (splitData['method'] == "Percentage") {
      List<String> percentages = splitData['values'].split(',');
      for (int i = 0; i < _selectedFriends.length; i++) {
        shares[_selectedFriends[i]] =
            (double.parse(percentages[i]) / 100) * totalAmount;
      }
    }

    return shares;
  }
}
