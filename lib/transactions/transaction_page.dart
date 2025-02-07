import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/providers/transaction_provider.dart';
import 'split_method_page.dart';
import 'package:flutter/services.dart';

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
  String _splitMethod = "Equal"; // ✅ Default method is a string, not a Map
  String _payer = 'You';
  List<String> _selectedFriends = [];
  Map<String, double> _participantShares = {}; // ✅ Correct structure

  @override
  Widget build(BuildContext context) {
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
            ),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
              ],
              decoration: const InputDecoration(labelText: 'Amount'),
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
            const SizedBox(height: 16),
            const Text("Participants & Contributions", style: TextStyle(fontWeight: FontWeight.bold)),
            Column(
              children: _participantShares.entries.map((entry) {
                return ListTile(
                  title: Text(entry.key),
                  trailing: Text("\$${entry.value.toStringAsFixed(2)}"),
                );
              }).toList(),
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
                    participantShares: _participantShares, // ✅ Correctly passing participantShares
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

  /// **Calculate Split Logic**
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
        shares[_selectedFriends[i]] = (double.parse(percentages[i]) / 100) * totalAmount;
      }
    }

    return shares;
  }
}
