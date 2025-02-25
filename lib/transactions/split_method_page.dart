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
  String selectedMethod = "Equal";

  @override
  void initState() {
    super.initState();
    selectedMethod = widget.splitMethod;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Split Method"),
        backgroundColor: Colors.teal,
      ),
      body: Column(
        children: [
          ListTile(
            title: const Text("Equal Split"),
            leading: Radio(
              value: "Equal",
              groupValue: selectedMethod,
              onChanged: (value) {
                setState(() => selectedMethod = value!);
              },
            ),
          ),
          ListTile(
            title: const Text("Custom Split"),
            leading: Radio(
              value: "Custom",
              groupValue: selectedMethod,
              onChanged: (value) {
                setState(() => selectedMethod = value!);
              },
            ),
          ),
          if (selectedMethod == "Custom")
            TextField(
              controller: _customController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                  labelText: "Enter custom amounts (comma separated)"),
            ),
          ListTile(
            title: const Text("Percentage Split"),
            leading: Radio(
              value: "Percentage",
              groupValue: selectedMethod,
              onChanged: (value) {
                setState(() => selectedMethod = value!);
              },
            ),
          ),
          if (selectedMethod == "Percentage")
            TextField(
              controller: _percentageController,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                  labelText: "Enter percentages (comma separated)"),
            ),
          ElevatedButton(
            onPressed: () {
              Map<String, dynamic> splitData = {
                "method": selectedMethod,
                "values": selectedMethod == "Custom"
                    ? _customController.text
                    : _percentageController.text,
              };
              widget.onSave(splitData);
              Navigator.pop(context);
            },
            child: const Text("Save Split Method"),
          ),
        ],
      ),
    );
  }
}
