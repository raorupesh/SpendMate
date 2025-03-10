import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class PaymentHistoryPage extends StatefulWidget {
  const PaymentHistoryPage({super.key});

  @override
  _PaymentHistoryPageState createState() => _PaymentHistoryPageState();
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _payments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPaymentHistory();
  }

  Future<void> _fetchPaymentHistory() async {
    setState(() => _isLoading = true);

    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Query transactions from `settled_transactions`
      final transactions = await _firestore
          .collection('settled_transactions')
          .get();

      List<Map<String, dynamic>> payments = [];

      for (var doc in transactions.docs) {
        final data = doc.data();

        final String debtClearedBy = data['debtClearedBy'] ?? 'Unknown';
        final String paidTo = data['paidTo'] ?? 'Unknown';
        final String description = data['description'] ?? 'Debt Settled';
        final double amount = (data['amount'] as num?)?.toDouble() ?? 0.0;
        final DateTime date = (data['date'] as Timestamp?)?.toDate() ?? DateTime.now();

        // Determine if the current user paid or received payment
        final bool userPaid = debtClearedBy == 'You' || debtClearedBy == userId;

        payments.add({
          'id': doc.id,
          'amount': amount,
          'date': date,
          'debtClearedBy': debtClearedBy,
          'paidTo': paidTo,
          'description': description,
          'userPaid': userPaid,
        });
      }

      setState(() {
        _payments = payments;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading payment history: $e')),
      );
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment History"),
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchPaymentHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : _payments.isEmpty
          ? _buildEmptyState()
          : _buildPaymentList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: Colors.teal.withOpacity(0.7)),
          const SizedBox(height: 16),
          const Text(
            "No payment history yet",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            "When you settle up with friends, your payments will appear here.",
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context); // Go back to settle up page
            },
            icon: const Icon(Icons.payment),
            label: const Text("Go to Settle Up"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.receipt_long, color: Colors.teal),
              const SizedBox(width: 8),
              const Text(
                "Your Payment History",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: _payments.length,
            itemBuilder: (context, index) {
              final payment = _payments[index];
              final bool userPaid = payment['userPaid'];
              final DateTime date = payment['date'];
              final String formattedDate = DateFormat('MMM d, yyyy • h:mm a').format(date);
              final String otherParty = userPaid ? payment['paidTo'] : payment['debtClearedBy'];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: userPaid ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              userPaid ? Icons.arrow_upward : Icons.arrow_downward,
                              color: userPaid ? Colors.red : Colors.green,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  userPaid ? "You paid" : "You received",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userPaid
                                      ? "You paid $otherParty"
                                      : "$otherParty paid you",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            "\$${payment['amount'].toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: userPaid ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formattedDate,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              // Show payment details in a dialog
                              _showPaymentDetails(payment);
                            },
                            icon: const Icon(Icons.info_outline, size: 16),
                            label: const Text("Details"),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.teal,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showPaymentDetails(Map<String, dynamic> payment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Payment Details"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailRow("Description", payment['description']),
            _detailRow("Type", payment['userPaid'] ? "Payment Sent" : "Payment Received"),
            _detailRow("Amount", "\$${payment['amount'].toStringAsFixed(2)}"),
            _detailRow("Debt Cleared By", payment['debtClearedBy']),
            _detailRow("Paid To", payment['paidTo']),
            _detailRow("Date", DateFormat('MMMM d, yyyy').format(payment['date'])),
            _detailRow("Time", DateFormat('h:mm a').format(payment['date'])),
            _detailRow("Transaction ID", payment['id']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}