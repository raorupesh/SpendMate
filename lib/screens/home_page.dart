import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For SystemNavigator to close app
import 'add_expense_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Close the app when back button is pressed
        SystemNavigator.pop(); // This will close the app
        return Future.value(false); // Prevent back navigation
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white, Colors.blue.shade200], // Soft gradient background
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Add space from the top and show "Your Section" title
              const SizedBox(height: 40), // Adds space from the top
              const Text(
                'Personal Section', // The section name
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 20),

              // Balance Display Section
              const Text(
                'Current Balance:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const Text(
                '\$2,500.00',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 20),

              // Recent Transactions Section
              const Text(
                'Recent Transactions:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              // List of transactions (sample items)
              Expanded(
                child: ListView(
                  children: const [
                    TransactionCard(title: 'Direct Transfer', amount: 500.00, icon: Icons.shopping_cart),
                    TransactionCard(title: 'Groceries', amount: -50.00, icon: Icons.shopping_cart),
                    TransactionCard(title: 'Bus Ticket', amount: -2.50, icon: Icons.directions_bus),
                    TransactionCard(title: 'Dinner', amount: -30.00, icon: Icons.restaurant),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Action Buttons for Add Expense and View Reports
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ActionButton(
                    label: 'Add Expense',
                    icon: Icons.add,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AddExpensePage()),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Transaction card widget
class TransactionCard extends StatelessWidget {
  const TransactionCard({
    required this.title,
    required this.amount,
    required this.icon,
    super.key,
  });

  final String title;
  final double amount;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.deepOrangeAccent), // Changed icon color to deep orange
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(amount < 0 ? 'Expense' : 'Income'),
        trailing: Text(
          '\$${amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: amount < 0 ? Colors.red : Colors.green, // Red for expenses, green for income
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// Action Button widget
class ActionButton extends StatelessWidget {
  const ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: Colors.white), // White icons for contrast
      label: Text(label, style: const TextStyle(color: Colors.white)),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.teal.shade600, // Teal button color
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}
