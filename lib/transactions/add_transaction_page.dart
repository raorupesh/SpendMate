import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:spendmate/providers/group_provider.dart';
import 'package:spendmate/providers/transaction_provider.dart';
import 'package:spendmate/transactions/split_method_page.dart';

class AddTransactionPage extends StatefulWidget {
  final String groupName;

  const AddTransactionPage({super.key, required this.groupName});

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
  String _selectedCategory = 'Others'; // Default category
  List<String> _groupMembers = [];
  bool isLoading = true;
  String? _groupId;
  bool _isSettled = false;
  Map<String, double> _participantShares = {};

  final List<String> _categories = ["Others", "Shopping", "Utility", "Food", "Grocery"];

  @override
  void initState() {
    super.initState();
    _fetchGroupData();
  }

  /// Fetches group data from Firestore
  Future<void> _fetchGroupData() async {
    final group = await Provider.of<GroupProvider>(context, listen: false)
        .getGroupByName(widget.groupName);

    if (group != null) {
      setState(() {
        _groupMembers = ['You', ...group.members]; // Always include "You"
        _paidBy = _groupMembers.first; // Default selection is "You"
        _groupId = group.id;
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Group not found!")),
      );
      Navigator.pop(context);
    }
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

  /// Calculate participant shares based on split method
  void _calculateShares() {
    final double totalAmount = double.tryParse(_amountController.text) ?? 0.0;
    final int memberCount = _groupMembers.length;

    _participantShares = {};

    switch (_splitMethod) {
      case 'Equal':
        final double sharePerPerson = totalAmount / memberCount;
        for (var member in _groupMembers) {
          _participantShares[member] = sharePerPerson;
        }
        break;

      case 'Custom':
        if (_splitValues.isNotEmpty) {
          final values = _splitValues.split(',');
          if (values.length == _groupMembers.length) {
            double total = values.map((v) => double.tryParse(v.trim()) ?? 0).reduce((a, b) => a + b);
            for (int i = 0; i < values.length; i++) {
              double? value = double.tryParse(values[i].trim());
              _participantShares[_groupMembers[i]] = (value ?? 0) / total * totalAmount;
            }
          }
        }
        break;

      case 'Percentage':
        if (_splitValues.isNotEmpty) {
          final percentages = _splitValues.split(',');
          if (percentages.length == _groupMembers.length) {
            double totalPercentage = percentages.map((p) => double.tryParse(p.trim()) ?? 0).reduce((a, b) => a + b);
            for (int i = 0; i < percentages.length; i++) {
              double? percentage = double.tryParse(percentages[i].trim());
              _participantShares[_groupMembers[i]] = (percentage ?? 0) / 100.0 * totalAmount;
            }
          }
        }
        break;

      default:
        final double sharePerPerson = totalAmount / memberCount;
        for (var member in _groupMembers) {
          _participantShares[member] = sharePerPerson;
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Expense'),
        backgroundColor: Colors.teal,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) =>
                value == null || value.isEmpty ? 'Please enter a description' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount (\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Please enter an amount';
                  if (double.tryParse(value) == null) return 'Please enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(DateFormat('MMM dd, yyyy').format(_selectedDate)),
                ),
              ),
              const SizedBox(height: 16),

              // Category Dropdown
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) setState(() => _selectedCategory = newValue);
                },
              ),
              const SizedBox(height: 16),

              // Paid By Dropdown
              DropdownButtonFormField<String>(
                value: _paidBy,
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
                  if (newValue != null) setState(() => _paidBy = newValue);
                },
              ),
              const SizedBox(height: 16),

              // Split Method Button (Box Format)
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
                  child: Text(_splitMethod),
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _calculateShares();

                    if (_groupId != null) {
                      await Provider.of<TransactionProvider>(context, listen: false).addTransaction(
                        _groupId!,
                        _descriptionController.text,
                        double.parse(_amountController.text),
                        _paidBy,
                        _selectedDate,
                        _participantShares,
                        _selectedCategory,
                        _isSettled,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Transaction saved successfully!")),
                      );

                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Error: Group ID not found!")),
                      );
                    }
                  }
                },
                child: const Text('Save Transaction', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}