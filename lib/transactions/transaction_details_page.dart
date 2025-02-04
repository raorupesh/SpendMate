import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/providers/transaction_provider.dart';

class TransactionDetailsPage extends StatefulWidget {
  final String groupName;
  final int transactionIndex;

  const TransactionDetailsPage({
    super.key,
    required this.groupName,
    required this.transactionIndex,
  });

  @override
  _TransactionDetailsPageState createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  DateTime _transactionDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    final group = Provider.of<GroupProvider>(context, listen: false)
        .getGroup(widget.groupName);
    final transaction = group.transactions[widget.transactionIndex];

    _descriptionController = TextEditingController(text: transaction.description);
    _amountController = TextEditingController(text: transaction.amount.toString());
    _transactionDate = transaction.date;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final group = Provider.of<GroupProvider>(context).getGroup(widget.groupName);
    final transaction = group.transactions[widget.transactionIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Transaction Details"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              // Delete transaction
              Provider.of<GroupProvider>(context, listen: false)
                  .deleteTransaction(widget.groupName, widget.transactionIndex);
              Navigator.pop(context); // Go back to Group Detail Page
            },
          ),
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to the edit form
              _showEditTransactionDialog(context, transaction);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Description: ${transaction.description}"),
            Text("Amount: \$${transaction.amount.toStringAsFixed(2)}"),
            Text("Date: ${transaction.date.toLocal().toString().split(' ')[0]}"),
            // You can add more fields like participants and their amounts if needed
          ],
        ),
      ),
    );
  }

  // Show the dialog for editing the transaction
  void _showEditTransactionDialog(BuildContext context, Transaction transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Edit Transaction"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Amount'),
                ),
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
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog without saving
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final amount = double.tryParse(_amountController.text);
                if (amount != null && _descriptionController.text.isNotEmpty) {
                  // Update the transaction
                  final updatedTransaction = Transaction(
                    description: _descriptionController.text,
                    amount: amount,
                    date: _transactionDate,
                    participants: transaction.participants, // Keep the same participants
                  );

                  // Update the transaction in the group provider
                  Provider.of<GroupProvider>(context, listen: false)
                      .updateTransaction(widget.groupName, widget.transactionIndex, updatedTransaction);

                  Navigator.pop(context); // Close the dialog and return to the group page
                }
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    );
  }
}
