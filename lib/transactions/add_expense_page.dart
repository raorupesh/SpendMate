import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'split_method_page.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController expenseNameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  String _splitMethod = "Equal";
  List<String> _participants = ["You", "Friend 1", "Friend 2"]; // Example participants
  Map<String, double> _participantShares = {};

  bool isSaveEnabled = false;
  String selectedDate = '';

  void validateFields() {
    setState(() {
      final isExpenseNameValid = expenseNameController.text.isNotEmpty;
      final isAmountValid = amountController.text.isNotEmpty &&
          RegExp(r'^\d+(\.\d{0,2})?$').hasMatch(amountController.text);
      isSaveEnabled = isExpenseNameValid && isAmountValid;
    });
  }

  void _openSplitMethodPage() async {
    final splitData = await Navigator.push(
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

    if (splitData != null) {
      setState(() {
        _splitMethod = splitData['method'];
        _participantShares = _calculateSplit(splitData);
      });
    }
  }

  /// **Split Calculation Logic**
  Map<String, double> _calculateSplit(Map<String, dynamic> splitData) {
    double totalAmount = double.tryParse(amountController.text) ?? 0.0;
    Map<String, double> shares = {};

    if (_splitMethod == "Equal") {
      double splitAmount = totalAmount / _participants.length;
      for (var person in _participants) {
        shares[person] = splitAmount;
      }
    } else if (_splitMethod == "Custom") {
      List<String> amounts = splitData['values'].split(',');
      for (int i = 0; i < _participants.length; i++) {
        shares[_participants[i]] = double.parse(amounts[i]);
      }
    } else if (_splitMethod == "Percentage") {
      List<String> percentages = splitData['values'].split(',');
      for (int i = 0; i < _participants.length; i++) {
        shares[_participants[i]] = (double.parse(percentages[i]) / 100) * totalAmount;
      }
    }

    return shares;
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
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$'))],
              decoration: const InputDecoration(labelText: 'Amount'),
              onChanged: (_) => validateFields(),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text("Split Method"),
              subtitle: Text(_splitMethod),
              onTap: _openSplitMethodPage,
            ),
            const SizedBox(height: 16),
            const Text("Participants & Split Amounts", style: TextStyle(fontWeight: FontWeight.bold)),
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
              onPressed: isSaveEnabled ? () {
                // Logic to save expense
                Navigator.pop(context);
              } : null,
              child: const Text("Save Expense"),
            ),
          ],
        ),
      ),
    );
  }
}
