import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:spendmate/providers/group_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionDetailsPage extends StatefulWidget {
  final String transactionId;
  final String groupId;

  const TransactionDetailsPage({super.key, required this.transactionId, required this.groupId});

  @override
  _TransactionDetailsPageState createState() => _TransactionDetailsPageState();
}

class _TransactionDetailsPageState extends State<TransactionDetailsPage> {
  late Map<String, double> _participantShares = {};
  double _amount = 0.0;
  String _splitMethod = "Equal";
  List<String> _groupMembers = [];

  @override
  void initState() {
    super.initState();
    _fetchGroupMembers();
  }

  /// Fetch group members from Firestore
  Future<void> _fetchGroupMembers() async {
    var groupDoc = await FirebaseFirestore.instance.collection('groups').doc(widget.groupId).get();
    if (groupDoc.exists) {
      setState(() {
        _groupMembers = List<String>.from(groupDoc['members']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance.collection('transactions').doc(widget.transactionId).snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
          return Scaffold(
            appBar: AppBar(title: const Text("Transaction Details")),
            body: const Center(child: Text("Transaction not found")),
          );
        }

        var transactionData = snapshot.data!.data() as Map<String, dynamic>;

        _amount = transactionData['amount'];
        _participantShares = Map<String, double>.from(transactionData['participantShares']);
        _splitMethod = transactionData['splitMethod'] ?? "Equal";

        return Scaffold(
          appBar: AppBar(
            title: const Text("Transaction Details"),
            backgroundColor: Colors.teal,
            elevation: 2,
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  _showDeleteConfirmationDialog(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  _showEditParticipantsDialog(context);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow("Description:", transactionData['description']),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      "Amount:",
                      "\$${_amount.toStringAsFixed(2)}",
                      valueColor: _amount < 0 ? Colors.red : Colors.green,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      "Date:",
                      DateFormat('EEEE, MMMM d, y').format((transactionData['date'] as Timestamp).toDate()),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    const Text("Participants & Contributions:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _participantShares.isNotEmpty
                        ? ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _participantShares.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        var entry = _participantShares.entries.elementAt(index);
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(entry.key),
                          trailing: Text("\$${entry.value.toStringAsFixed(2)}"),
                        );
                      },
                    )
                        : const Text(
                      "No participants added.",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(
          value,
          style: TextStyle(fontSize: 16, color: valueColor),
        ),
      ],
    );
  }

  void _showDeleteConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Transaction"),
          content: const Text("Are you sure you want to delete this transaction?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                await Provider.of<GroupProvider>(context, listen: false)
                    .deleteTransaction(widget.transactionId);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showEditParticipantsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text("Edit Participants"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: _groupMembers.map((participant) => CheckboxListTile(
                  title: Text(participant),
                  value: _participantShares.containsKey(participant),
                  onChanged: (bool? checked) {
                    setState(() {
                      if (checked == true) {
                        _participantShares[participant] = 0.0; // Default share
                      } else {
                        _participantShares.remove(participant);
                      }
                    });
                  },
                )).toList(),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                TextButton(
                  onPressed: () async {
                    _recalculateSplit();
                    await FirebaseFirestore.instance
                        .collection('transactions')
                        .doc(widget.transactionId)
                        .update({'participantShares': _participantShares});
                    Navigator.pop(context);
                  },
                  child: const Text("Save"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _recalculateSplit() {
    double totalAmount = _amount;
    int memberCount = _participantShares.length;

    if (_splitMethod == "Equal" && memberCount > 0) {
      double sharePerPerson = totalAmount / memberCount;
      _participantShares.updateAll((key, value) => sharePerPerson);
    }
  }
}
