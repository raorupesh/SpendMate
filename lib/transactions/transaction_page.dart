import 'package:flutter/material.dart';

class SplitMethodPage extends StatefulWidget {
  final String splitMethod;
  final ValueChanged<Map<String, dynamic>> onSave;

  const SplitMethodPage(
      {super.key, required this.splitMethod, required this.onSave});

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
        title: const Text("Select Split Method"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              title: const Text("Equal Split"),
              leading: Radio<String>(
                value: "Equal",
                groupValue: selectedMethod,
                onChanged: (value) {
                  setState(() => selectedMethod = value!);
                },
              ),
            ),
            ListTile(
              title: const Text("Custom Split"),
              leading: Radio<String>(
                value: "Custom",
                groupValue: selectedMethod,
                onChanged: (value) {
                  setState(() => selectedMethod = value!);
                },
              ),
            ),
            if (selectedMethod == "Custom")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _customController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: "Enter custom amounts (comma separated)",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            ListTile(
              title: const Text("Percentage Split"),
              leading: Radio<String>(
                value: "Percentage",
                groupValue: selectedMethod,
                onChanged: (value) {
                  setState(() => selectedMethod = value!);
                },
              ),
            ),
            if (selectedMethod == "Percentage")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: _percentageController,
                  keyboardType: TextInputType.text,
                  decoration: const InputDecoration(
                    labelText: "Enter percentages (comma separated)",
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
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
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                ),
                child: const Text("Save Split Method",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}