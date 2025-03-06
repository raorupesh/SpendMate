import 'package:flutter/material.dart';

class SplitMethodPage extends StatefulWidget {
  final String splitMethod;
  final ValueChanged<Map<String, dynamic>> onSave;

  const SplitMethodPage({
    super.key,
    required this.splitMethod,
    required this.onSave
  });

  @override
  _SplitMethodPageState createState() => _SplitMethodPageState();
}

class _SplitMethodPageState extends State<SplitMethodPage> {
  final TextEditingController _customController = TextEditingController();
  final TextEditingController _percentageController = TextEditingController();
  late String selectedMethod;

  @override
  void initState() {
    super.initState();
    selectedMethod = widget.splitMethod;
  }

  @override
  void dispose() {
    _customController.dispose();
    _percentageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Split Method",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Column(
                    children: [
                      _buildMethodTile(
                        "Equal Split",
                        "Everyone pays the same amount",
                        "Equal",
                        Icons.balance,
                      ),
                      const Divider(height: 1),
                      _buildMethodTile(
                        "Custom Split",
                        "Specify exact amounts for each person",
                        "Custom",
                        Icons.edit,
                      ),
                      if (selectedMethod == "Custom")
                        _buildInputField(
                          _customController,
                          "Enter custom amounts (comma separated)",
                          "Example: 10.50, 15.75, 20.00",
                        ),
                      const Divider(height: 1),
                      _buildMethodTile(
                        "Percentage Split",
                        "Split by percentage contributions",
                        "Percentage",
                        Icons.pie_chart,
                      ),
                      if (selectedMethod == "Percentage")
                        _buildInputField(
                          _percentageController,
                          "Enter percentages (comma separated)",
                          "Example: 40, 30, 30 (must add up to 100)",
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveSplitMethod,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  "Save Split Method",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMethodTile(
      String title,
      String subtitle,
      String value,
      IconData icon,
      ) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: selectedMethod == value ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(subtitle),
      leading: Radio<String>(
        value: value,
        groupValue: selectedMethod,
        activeColor: Colors.teal,
        onChanged: (value) {
          setState(() => selectedMethod = value!);
        },
      ),
      trailing: Icon(
        icon,
        color: selectedMethod == value ? Colors.teal : Colors.grey,
      ),
      onTap: () {
        setState(() => selectedMethod = value);
      },
    );
  }

  Widget _buildInputField(
      TextEditingController controller,
      String labelText,
      String hintText,
      ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(56.0, 0, 16.0, 16.0),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.teal, width: 2),
          ),
        ),
      ),
    );
  }

  void _saveSplitMethod() {
    Map<String, dynamic> splitData = {
      "method": selectedMethod,
      "values": selectedMethod == "Custom"
          ? _customController.text
          : selectedMethod == "Percentage"
          ? _percentageController.text
          : "",
    };
    widget.onSave(splitData);
    Navigator.pop(context);
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Split Method Info"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text("Equal Split", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("The total amount will be divided equally among all participants."),
              SizedBox(height: 12),
              Text("Custom Split", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Specify exact amounts for each person. The amounts should add up to the total bill."),
              SizedBox(height: 12),
              Text("Percentage Split", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("Define what percentage of the bill each person will pay. Percentages should total 100%."),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Got it", style: TextStyle(color: Colors.teal)),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        );
      },
    );
  }
}