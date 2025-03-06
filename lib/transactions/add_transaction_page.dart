import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:spendmate/providers/transaction_provider.dart';
import 'package:spendmate/transactions/split_method_page.dart';

class AddTransactionPage extends StatefulWidget {
  final String groupName;

  const AddTransactionPage({Key? key, required this.groupName}) : super(key: key);

  @override
  _AddTransactionPageState createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends State<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String _paidBy = '';
  String _splitMethod = 'Equal';
  String _splitValues = '';
  late List<String> _groupMembers;
  Map<String, double> _participantShares = {};

  @override
  void initState() {
    super.initState();
    // Get group members from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _groupMembers = Provider.of<GroupProvider>(context, listen: false)
          .getGroup(widget.groupName)
          .members;
      if (_groupMembers.isNotEmpty) {
        setState(() {
          _paidBy = _groupMembers[0];
        });
      }
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Calculate participant shares based on split method
  void _calculateShares() {
    final double totalAmount = double.tryParse(_amountController.text) ?? 0.0;

    // Reset shares
    _participantShares = {};

    switch (_splitMethod) {
      case 'Equal':
      // Split equally among all members
        final double sharePerPerson = totalAmount / _groupMembers.length;
        for (var member in _groupMembers) {
          _participantShares[member] = sharePerPerson;
        }
        break;

      case 'Custom':
      // Process custom split values
        if (_splitValues.isNotEmpty) {
          final values = _splitValues.split(',');
          if (values.length == _groupMembers.length) {
            double total = 0.0;

            // First pass: calculate total of provided values
            for (int i = 0; i < values.length; i++) {
              final double? value = double.tryParse(values[i].trim());
              if (value != null) {
                total += value;
              }
            }

            // Second pass: calculate proportions of total amount
            if (total > 0) {
              for (int i = 0; i < values.length; i++) {
                final double? value = double.tryParse(values[i].trim());
                if (value != null) {
                  _participantShares[_groupMembers[i]] = (value / total) * totalAmount;
                } else {
                  _participantShares[_groupMembers[i]] = 0.0;
                }
              }
            }
          }
        }
        break;

      case 'Percentage':
      // Process percentage split
        if (_splitValues.isNotEmpty) {
          final percentages = _splitValues.split(',');
          if (percentages.length == _groupMembers.length) {
            double totalPercentage = 0.0;

            // First pass: calculate total percentage
            for (int i = 0; i < percentages.length; i++) {
              final double? percentage = double.tryParse(percentages[i].trim());
              if (percentage != null) {
                totalPercentage += percentage;
              }
            }

            // Second pass: calculate amounts based on percentages
            if (totalPercentage > 0) {
              for (int i = 0; i < percentages.length; i++) {
                final double? percentage = double.tryParse(percentages[i].trim());
                if (percentage != null) {
                  _participantShares[_groupMembers[i]] = (percentage / 100.0) * totalAmount;
                } else {
                  _participantShares[_groupMembers[i]] = 0.0;
                }
              }
            }
          }
        }
        break;

      default:
      // Default to equal split
        final double sharePerPerson = totalAmount / _groupMembers.length;
        for (var member in _groupMembers) {
          _participantShares[member] = sharePerPerson;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = Provider.of<GroupProvider>(context);
    final group = groupProvider.getGroup(widget.groupName);
    _groupMembers = group.members;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Description
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date Picker
              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    DateFormat('MMM dd, yyyy').format(_selectedDate),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Paid By Dropdown
              DropdownButtonFormField<String>(
                value: _paidBy.isEmpty && _groupMembers.isNotEmpty ? _groupMembers[0] : _paidBy,
                decoration: const InputDecoration(
                  labelText: 'Paid By',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                items: _groupMembers.map((String member) {
                  return DropdownMenuItem<String>(
                    value: member,
                    child: Text(member),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _paidBy = newValue;
                    });
                  }
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select who paid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Split Method
              InkWell(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SplitMethodPage(
                        splitMethod: _splitMethod,
                        onSave: (Map<String, dynamic> data) {
                          setState(() {
                            _splitMethod = data['method'] as String;
                            _splitValues = data['values'] as String;
                          });
                        },
                      ),
                    ),
                  );
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Split Method',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.splitscreen),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(_splitMethod),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Split details if not equal
              if (_splitMethod != 'Equal' && _splitValues.isNotEmpty)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Split Details (${_splitMethod}):',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(_splitValues),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Calculate shares based on split method
                      _calculateShares();

                      // Create new transaction
                      final newTransaction = Transaction(
                        description: _descriptionController.text,
                        amount: double.parse(_amountController.text),
                        date: _selectedDate,
                        paidBy: _paidBy,
                        participantShares: _participantShares,
                      );

                      // Add transaction to group
                      groupProvider.addTransactionByGroupName(
                        widget.groupName,
                        newTransaction,
                      );

                      // Navigate back
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    'Save Transaction',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}