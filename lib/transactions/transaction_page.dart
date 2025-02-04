import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/providers/transaction_provider.dart';
import 'split_method_page.dart';
import 'package:spendmate/groups/friends_page.dart';

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
  String _splitMethod = 'Equal';
  String _payer = 'You';
  List<String> _selectedFriends = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Transaction"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            onPressed: () async {
              final selectedFriends = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FriendsPage(),
                ),
              );
              if (selectedFriends != null) {
                setState(() {
                  _selectedFriends = List<String>.from(selectedFriends);
                });
              }
            },
          ),
        ],
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
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Amount'),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text("Paid by"),
              subtitle: Text(_payer),
              onTap: () async {
                String? selectedPayer = await showDialog<String>(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text("Select Payer"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: ['You', ..._selectedFriends]
                            .map((e) => ListTile(
                          title: Text(e),
                          onTap: () {
                            Navigator.pop(context, e);
                          },
                        ))
                            .toList(),
                      ),
                    );
                  },
                );
                if (selectedPayer != null) {
                  setState(() {
                    _payer = selectedPayer;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text("Date of Transaction"),
              subtitle: Text("${_transactionDate.toLocal()}".split(' ')[0]),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _transactionDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (picked != null && picked != _transactionDate) {
                  setState(() {
                    _transactionDate = picked;
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
                      onSave: (method) {
                        setState(() {
                          _splitMethod = method;
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
                    description: _descriptionController.text,
                    amount: amount,
                    date: _transactionDate,
                    participants: _selectedFriends,
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
}
