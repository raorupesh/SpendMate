import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:spendmate/screens/settlle_up_page.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  double totalOwings = 0.0;
  double totalIOwe = 0.0;
  bool isLoading = true;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // New variables for last transaction and chores
  Map<String, dynamic>? lastTransaction;
  List<Map<String, dynamic>> myChores = [];

  @override
  void initState() {
    super.initState();
    _fetchFinancialSummary();
    _fetchLastTransaction();
    _fetchMyChores();
  }

  Future<void> _fetchFinancialSummary() async {
    setState(() => isLoading = true);
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    double owingsSum = 0.0;
    double iOweSum = 0.0;

    // Fetch all transactions
    final transactions = await _firestore.collection('transactions')
        .where('isSettled', isEqualTo: false)
        .get();


    for (var doc in transactions.docs) {
      final data = doc.data();
      String paidBy = data['paidBy'];
      Map<String, dynamic> participantShares = data['participantShares'] ?? {};

      if (paidBy == 'You') {
        // People Owe Me: Sum of participant shares when I paid
        participantShares.forEach((key, value) {
          if (key != 'You') {
            owingsSum += (value as num).toDouble();
          }
        });
      }
      else if (paidBy != 'You') {
        participantShares.forEach((key, value) {
          if (key == 'You') {
            iOweSum += (participantShares['You'] as num).toDouble();
          }
        });
      }
    }

    setState(() {
      totalOwings = owingsSum;
      totalIOwe = iOweSum;
      isLoading = false;
    });
  }

  // New method to fetch the last transaction
  Future<void> _fetchLastTransaction() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final transactionsQuery = await _firestore.collection('settled_transactions')
        .limit(1)
        .get();

    if (transactionsQuery.docs.isNotEmpty) {
      setState(() {
        lastTransaction = {
          ...transactionsQuery.docs.first.data(),
          'id': transactionsQuery.docs.first.id
        };
      });
    }
  }


  Future<void> _fetchMyChores() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final choresQuery = await FirebaseFirestore.instance
        .collection('chores')
        .where(Filter.and(
      Filter("userId", isEqualTo: userId),
      Filter("participants", arrayContains: "You"),
    ))
        .get();

    List<Map<String, dynamic>> chores = [];
    for (var doc in choresQuery.docs) {
      chores.add({
        ...doc.data(),
        'id': doc.id
      });
    }

    setState(() {
      myChores = chores;
    });
  }


  // Method to refresh all data
  Future<void> _refreshAllData() async {
    setState(() => isLoading = true);
    await Future.wait([
      _fetchFinancialSummary(),
      _fetchLastTransaction(),
      _fetchMyChores()
    ]);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final netBalance = totalOwings - totalIOwe;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return WillPopScope(
        onWillPop: () async => false, // Disables back button press
    child: Scaffold(
      appBar: AppBar(
        title: const Text('SpendMate',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshAllData,
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDarkMode
                ? [Colors.grey.shade900, Colors.black87]
                : [Colors.white, Colors.blue.shade50],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: _refreshAllData,
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildNetBalanceCard(netBalance),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: _buildSummaryCard(
                        "People Owe Me",
                        totalOwings,
                        Icons.arrow_downward,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildSummaryCard(
                        "I Owe Others",
                        totalIOwe,
                        Icons.arrow_upward,
                        Colors.redAccent,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Last Transaction Section
                _buildSectionTitle("Last Transaction"),
                const SizedBox(height: 8),
                _buildLastTransactionCard(),

                const SizedBox(height: 24),

                // My Chores Section
                _buildSectionTitle("My Chores"),
                const SizedBox(height: 8),
                ...myChores.map((chore) => _buildChoreCard(chore)).toList(),
                if (myChores.isEmpty) _buildEmptyStateCard("No chores assigned to you"),

                const SizedBox(height: 24),
                _buildSettleUpButton(context),
              ],
            ),
          ),
        ),
      ),
    )
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white70
              : Colors.black87,
        ),
      ),
    );
  }

  Widget _buildLastTransactionCard() {
    if (lastTransaction == null) {
      return _buildEmptyStateCard("No transactions found");
    }

    final transaction = lastTransaction!;
    final amount = transaction['amount'] is num
        ? (transaction['amount'] as num).toDouble()
        : 0.0;
    final description = transaction['description'] ?? 'Unknown';
    final paidTo = transaction['paidTo'] ?? 'Unknown';
    final date = transaction['timestamp'] != null
        ? (transaction['timestamp'] as Timestamp).toDate()
        : DateTime.now();
    final formattedDate = DateFormat('MMM d, yyyy').format(date);
    final isUserPayer = paidTo == FirebaseAuth.instance.currentUser?.uid;
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: isUserPayer ? Colors.teal.shade100 : Colors.orange.shade100,
                      child: Icon(
                        isUserPayer ? Icons.arrow_downward: Icons.arrow_upward,
                        color: isUserPayer ? Colors.teal : Colors.red,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            description,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            isUserPayer ? 'You paid' : 'Paid to $paidTo' ,
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${amount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isUserPayer ? Colors.teal : Colors.orange,
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white60
                                : Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
  }

  Widget _buildChoreCard(Map<String, dynamic> chore) {
    print(chore);
    final String choreName = chore['choreName'] ?? 'Untitled Chore';
    final Map<String, dynamic> directAssignments = chore['directAssignments'] ?? {};

    // Get today's weekday
    final String today = DateFormat('EEEE').format(DateTime.now()); // Example: "Monday"
    // Get chores assigned to "You" for today
    String? assignedTask;
    directAssignments.forEach((participant, dynamic tasks) {
      if (participant == "You"  && tasks.containsKey(today)) {
        assignedTask = tasks[today]; // Get the assigned task for today
      }
    });

    // If no task assigned to "You" today, return an empty container
    if (assignedTask == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment, color: Colors.teal),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    choreName,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    "Today's Task",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.blue),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              "Task: $assignedTask", // Show today's assigned task
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildEmptyStateCard(String message) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.center,
        height: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white54
                  : Colors.black38,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white54
                    : Colors.black38,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNetBalanceCard(double netBalance) {
    final isPositive = netBalance >= 0;
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: isPositive
                ? [Colors.teal.shade300, Colors.teal.shade600]
                : [Colors.orange.shade300, Colors.red.shade500],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Net Balance',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '\$${netBalance.abs().toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  isPositive ? Icons.trending_up : Icons.trending_down,
                  color: Colors.white,
                ),
                const Spacer(),
                Text(
                  isPositive ? 'You\'re owed' : 'You owe',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, double amount, IconData icon, Color color) => Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color.withOpacity(0.8), size: 18),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color.withOpacity(0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    ),
  );

  Widget _buildSettleUpButton(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 54,
    child: ElevatedButton.icon(
      onPressed: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => SettleUpPage()),
      ),
      icon: const Icon(Icons.handshake, color: Colors.white),
      label: const Text(
        "SETTLE UP",
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
      ),
    ),
  );
}