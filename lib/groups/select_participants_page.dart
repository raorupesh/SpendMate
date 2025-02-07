import 'package:flutter/material.dart';

class SelectParticipantsPage extends StatefulWidget {
  final List<String> members;
  final List<String> selectedParticipants;

  const SelectParticipantsPage(
      {super.key, required this.members, required this.selectedParticipants});

  @override
  _SelectParticipantsPageState createState() => _SelectParticipantsPageState();
}

class _SelectParticipantsPageState extends State<SelectParticipantsPage> {
  late Set<String> selectedParticipants;

  @override
  void initState() {
    super.initState();
    selectedParticipants =
        Set.from(widget.selectedParticipants); //Load selections
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Participants"),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(
                context,
                selectedParticipants
                    .toList()); //Pass updated selections back
          },
        ),
      ),
      body: ListView(
        children: widget.members.map((member) {
          return CheckboxListTile(
            title: Text(member),
            value: selectedParticipants.contains(member),
            onChanged: (bool? value) {
              setState(() {
                if (value == true) {
                  selectedParticipants
                      .add(member); //Adds participant instantly
                } else {
                  selectedParticipants.remove(member); //Removes instantly
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }
}
