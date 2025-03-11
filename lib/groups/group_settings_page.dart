import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/groups/add_group_members_page.dart';
import 'package:spendmate/groups/groups_page.dart';
import 'package:spendmate/providers/group_provider.dart';

class GroupSettingsPage extends StatefulWidget {
  final String groupId;
  final String groupName;
  final List<String> groupMembers;
  final Function(String) onLeaveGroup;

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
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            widget.groupName,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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

// Modify Members Button
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

                        await Provider.of<GroupProvider>(context, listen: false)
                            .updateGroupMembers(widget.groupId, updatedMembers);

                        Navigator.popUntil(context, ModalRoute.withName('/'));
                      }
                    },
                  ),
                ),
              ],
            ),



            const SizedBox(height: 16),

            // Leave Group Button
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
                onPressed: () async {
                  bool confirm = await _confirmLeaveGroup(context);
                  if (confirm) {
                    setState(() {
                      isLoading = true;
                    });

                    try {
                      String userId = FirebaseAuth.instance.currentUser?.uid ?? "You";

                      await Provider.of<GroupProvider>(context, listen: false)
                          .leaveGroup(widget.groupId, userId);
                      // Call the provided onLeaveGroup callback function
                      widget.onLeaveGroup(widget.groupId);

                      // Show success message
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("You have left the group")),
                      );

                      // Navigate back to Groups Page and remove the current screen
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (context) => const GroupsPage()),
                            (route) => false, // Remove all previous routes
                      );
                    } catch (e) {
                      // Show error message
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error leaving group: $e")),
                      );
                    } finally {
                      if (mounted) {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                  }
                }

            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmLeaveGroup(BuildContext context) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Leave Group"),
          content: const Text("Are you sure you want to leave this group?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Leave"),
            ),
          ],
        );
      },
    ) ??
        false;
  }
}
