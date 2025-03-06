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
    selectedParticipants = Set.from(widget.selectedParticipants);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Participants"),
        backgroundColor: Colors.teal,
        elevation: 2, // Add subtle shadow
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, selectedParticipants.toList());
          },
        ),
      ),
      body: Card( // Wrap the list in a Card
        elevation: 4,
        margin: const EdgeInsets.all(8.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListView.separated( // Use ListView.separated for dividers
          itemCount: widget.members.length,
          separatorBuilder: (context, index) => const Divider(height: 1), // Add subtle dividers
          itemBuilder: (context, index) {
            final member = widget.members[index];
            return CheckboxListTile(
              title: Text(member),
              value: selectedParticipants.contains(member),
              onChanged: (bool? value) {
                setState(() {
                  if (value == true) {
                    selectedParticipants.add(member);
                  } else {
                    selectedParticipants.remove(member);
                  }
                });
              },
              activeColor: Colors.teal, // Customize checkbox active color
              controlAffinity: ListTileControlAffinity.leading, // Checkbox on the left
              contentPadding: const EdgeInsets.symmetric(horizontal: 16.0), // Add padding
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, selectedParticipants.toList());
        },
        backgroundColor: Colors.teal,
        elevation: 4, // Add elevation
        child: const Icon(Icons.check),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}