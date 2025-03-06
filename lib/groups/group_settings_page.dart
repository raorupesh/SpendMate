import 'package:flutter/material.dart';
import 'package:spendmate/groups/add_group_members_page.dart';

class GroupSettingsPage extends StatefulWidget {
  final String groupId; // Added group ID for database operations
  final String groupName;
  final List<String> groupMembers;
  final Function(String) onLeaveGroup; // Callback to handle group leaving

  const GroupSettingsPage({
    super.key,
    required this.groupId,
    required this.groupName,
    required this.groupMembers,
    required this.onLeaveGroup,
  });

  @override
  _GroupSettingsPageState createState() => _GroupSettingsPageState();
}

class _GroupSettingsPageState extends State<GroupSettingsPage> {
  late List<String> groupMembers;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    groupMembers = widget.groupMembers;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Group Settings"),
        backgroundColor: Colors.teal,
        elevation: 2,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Group Name Section
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const Icon(Icons.group, size: 32, color: Colors.teal),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Group Name",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            widget.groupName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Group Members Section
            const Text(
              "Group Members",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            Expanded(
              child: Card(
                elevation: 1,
                child: ListView.separated(
                  itemCount: groupMembers.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.teal.shade100,
                        child: Text(
                          groupMembers[index][0].toUpperCase(),
                          style: TextStyle(color: Colors.teal.shade700),
                        ),
                      ),
                      title: Text(groupMembers[index]),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Buttons Section
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text("Modify Members"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () async {
                      final updatedMembers = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddGroupMembersPage(
                            preselectedFriends: groupMembers,
                          ),
                        ),
                      );
                      if (updatedMembers != null) {
                        setState(() {
                          groupMembers = updatedMembers;
                        });
                        Navigator.pop(context, {'members': updatedMembers, 'action': 'update'});
                      }
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              icon: const Icon(Icons.exit_to_app),
              label: const Text("Leave Group"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                _showLeaveGroupDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLeaveGroupDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Colors.orange),
              const SizedBox(width: 10),
              const Text("Leave Group"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Are you sure you want to leave \"${widget.groupName}\"?"),
              const SizedBox(height: 12),
              const Text(
                "You will no longer have access to this group's expenses.",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });

                Navigator.pop(context); // Close dialog

                // Call the callback function to handle group leaving
                widget.onLeaveGroup(widget.groupId);

                // Return to groups list with leave action
                Navigator.pop(context, {'action': 'leave', 'groupId': widget.groupId});
              },
              child: const Text("Leave Group"),
            ),
          ],
        );
      },
    );
  }
}