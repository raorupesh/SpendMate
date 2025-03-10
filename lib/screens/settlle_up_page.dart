import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spendmate/screens/payments_history_page.dart';

class SettleUpPage extends StatefulWidget {
  const SettleUpPage({super.key});

  @override
  _SettleUpPageState createState() => _SettleUpPageState();
}

class _SettleUpPageState extends State<SettleUpPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _debts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDebts();
  }

  /// Fetch unsettled transactions
  Future<void> _fetchDebts() async {
    setState(() => _isLoading = true);

    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final transactions = await _firestore.collection('transactions')
          .where('isSettled', isEqualTo: false).get();
      Map<String, double> debts = {};

      for (var doc in transactions.docs) {
        final data = doc.data();
        String paidBy = data['paidBy'];
        Map<String, dynamic> participantShares = data['participantShares'] ?? {};
        if (paidBy != 'You' && participantShares.containsKey('You')) {
          double amountOwed = (participantShares['You'] as num).toDouble();

          if (debts.containsKey(paidBy)) {
            debts[paidBy] = debts[paidBy]! + amountOwed;
          } else {
            debts[paidBy] = amountOwed;
          }
        }
      }

      setState(() {
        _debts = debts.entries
            .map((entry) => {
          'id': entry.key,
          'name': entry.key, // PaidBy contains the name of the person
          'amount': entry.value
        })
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading debts: $e')),
      );
      setState(() => _isLoading = false);
    }
  }


  void _showSettleDialog(String recipientId, String name, double amount) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Settle with $name',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Amount: \$${amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.red)),
                ),
                ElevatedButton(
                  onPressed: () => _settleDebt(recipientId, amount),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                  ),
                  child: const Text('Confirm Payment'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _settleDebt(String recipientId, double amount) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;
    try {
      // Fetch the transaction where `paidBy` is the recipient and `isSettled` is false
      final transactions = await _firestore
          .collection('transactions')
          .where('paidBy', isEqualTo: recipientId)
          .where('isSettled', isEqualTo: false)
          .get();

      if (transactions.docs.isNotEmpty) {
        for (var doc in transactions.docs) {
          await _firestore.collection('transactions').doc(doc.id).update({
            'isSettled': true,
          });

          await _firestore.collection('settled_transactions').add({
            'description':'Debt Settled',
            'amount':amount,
            'debtClearedBy':'You',
            'paidTo':recipientId,
            'date':Timestamp.now(),
          });

        }


        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment recorded successfully!')),
        );

        await _fetchDebts(); // Refresh debts

        // Navigate to Payment History Page after successful payment
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PaymentHistoryPage()),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No unsettled transaction found for this payment.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to record payment: $e')),
      );
    }
  }

  void _navigateToPaymentHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PaymentHistoryPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settle Up"),
        backgroundColor: Colors.teal,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchDebts,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.teal))
          : _debts.isEmpty
          ? _buildEmptyState()
          : _buildDebtsList(),

      // Floating Action Button for Payment History at Bottom Right
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToPaymentHistory,
        icon: const Icon(Icons.history),
        label: const Text("Payment History"),
        backgroundColor: Colors.teal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat, // Bottom Right
    );
  }


Widget _buildEmptyState() {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_outline, size: 80, color: Colors.teal.withOpacity(0.7)),
            const SizedBox(height: 16),
            const Text(
              "You're all settled up!",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              "You don't owe anyone money right now.",
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    Widget _buildDebtsList() {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.account_balance_wallet, color: Colors.teal),
                const SizedBox(width: 8),
                const Text(
                  "People You Owe",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _fetchDebts,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text("Refresh"),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(),
            Expanded(
              child: ListView.separated(
                itemCount: _debts.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final debt = _debts[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.withOpacity(0.2),
                      child: Text(
                        debt['name'].toString().substring(0, 1).toUpperCase(),
                        style: const TextStyle(color: Colors.teal),
                      ),
                    ),
                    title: Text(
                      debt['name'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text('You owe them'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "\$${debt['amount'].toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.teal,
                          ),
                        ),
                        const SizedBox(width: 12),
                        ElevatedButton(
                          onPressed: () => _showSettleDialog(
                            debt['id'],
                            debt['name'],
                            debt['amount'],
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text("Pay"),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

  }
