import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  _AddExpensePageState createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  final TextEditingController expenseNameController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  final FocusNode expenseNameFocusNode = FocusNode();
  final FocusNode amountFocusNode = FocusNode();
  final FocusNode notesFocusNode = FocusNode();

  bool isSaveEnabled = false; // Store button state
  String selectedDate = ''; // Store selected date

  // Validate both fields and update the button state
  void validateFields() {
    setState(() {
      final isExpenseNameValid = expenseNameController.text.isNotEmpty &&
          expenseNameController.text.length <= 100;
      final isAmountValid = amountController.text.isNotEmpty &&
          RegExp(r'^\d+(\.\d{0,2})?$').hasMatch(amountController.text);

      isSaveEnabled = isExpenseNameValid && isAmountValid;
    });
  }

  // Function to show Date Picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != DateTime.now()) {
      setState(() {
        selectedDate = DateFormat('yyyy-MM-dd').format(picked);
      });

      // Revalidate fields when date is selected
      validateFields();
    }
  }

  // Function to open the text editor for notes
  void _openTextEditor(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Notes'),
          content: TextField(
            controller: notesController,
            textCapitalization: TextCapitalization.words,
            maxLines: 5,
            decoration: const InputDecoration(
              hintText: 'Write your notes here...',
            ),
            onChanged: (value) {
              validateFields();
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // Revalidate fields when notes are updated
                  validateFields();
                });
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal.shade400, // Keeps AppBar teal
        title: const Text('Add Expense'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Navigate back to the HomePage
            Navigator.pop(context);
          },
        ),
      ),
      backgroundColor: Colors.teal.shade50,
      // Light background color for contrast
      body: Center(
        // Center the whole body content vertically and horizontally
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            elevation: 8,
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Enter Expense Details:',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Expense Name Field (Text only, max 100 characters)
                  TextField(
                    controller: expenseNameController,
                    textCapitalization: TextCapitalization.words,
                    focusNode: expenseNameFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Expense Name',
                      labelStyle: TextStyle(color: Colors.teal.shade700),
                      filled: true,
                      fillColor: Colors.teal.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.text,
                    inputFormatters: [
                      // Allow only alphabets and spaces
                      FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))
                    ],
                    onChanged: (value) {
                      // Validate fields on each change
                      validateFields();
                    },
                  ),
                  const SizedBox(height: 20),
                  // Amount Field
                  TextField(
                    controller: amountController,
                    focusNode: amountFocusNode,
                    decoration: InputDecoration(
                      labelText: 'Amount',
                      labelStyle: TextStyle(color: Colors.teal.shade700),
                      filled: true,
                      fillColor: Colors.teal.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      // Allow only digits and a decimal point
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+(\.\d{0,2})?$'))
                    ],
                    onChanged: (value) {
                      // Validate fields on each change
                      validateFields();
                    },
                  ),
                  const SizedBox(height: 20),
                  // Transaction Date and Notes Field in a Row

                  const SizedBox(height: 30),
                  // Save Button
                  Center(
                    child: ElevatedButton(
                      onPressed: isSaveEnabled
                          ? () {
                              // Save Expense and navigate to home page
                              Navigator.pop(
                                  context); // Go back to HomePage after saving
                            }
                          : null, // Disable button if fields are not valid
                      child: const Text('Save Expense'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade300,
                        // Gradient colors for modern look
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                        textStyle: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
