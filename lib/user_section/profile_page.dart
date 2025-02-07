import 'package:flutter/material.dart';

import 'login_page.dart'; // Import LoginPage

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isPhoneNumberVisible = false; // Toggle for showing/hiding phone number
  String _selectedTimezone = 'PST'; // Default selected timezone
  String _selectedCurrency = 'USD'; // Default selected currency

  final List<String> _timezones = ['PST', 'CST', 'EST', 'GMT', 'IST'];
  final List<String> _currencies = ['USD', 'EUR', 'INR', 'GBP', 'AUD'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Profile image
            const CircleAvatar(
              radius: 80,
              backgroundImage: AssetImage('assets/images/user_image.png'),
            ),
            const SizedBox(height: 16),

            // Full Name (Bold header)
            const Text(
              "Full Name:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text(
              "John Doe",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),

            // Email (Bold header)
            const Text(
              "Email ID:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text("johndoe@example.com", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),

            // Phone Number with Eye Icon (Bold header)
            const Text(
              "Phone:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Row(
              children: [
                Text(
                  _isPhoneNumberVisible ? "+1 234 567 890" : "**********",
                  // Hidden phone number
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: Icon(
                    _isPhoneNumberVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                    color: Colors.teal,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPhoneNumberVisible = !_isPhoneNumberVisible;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Currency Dropdown (Bold header)
            const Text(
              "Currency",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            DropdownButton<String>(
              value: _selectedCurrency,
              items: _currencies
                  .map((currency) => DropdownMenuItem<String>(
                        value: currency,
                        child: Text(currency),
                      ))
                  .toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedCurrency = newValue!;
                });
              },
              isExpanded: true,
              dropdownColor: Colors.teal.shade50,
              style: const TextStyle(color: Colors.teal),
              iconEnabledColor: Colors.teal,
              underline: Container(),
            ),
            const SizedBox(height: 16),

            // Language (Bold header)
            const Text(
              "Language:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              "English",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 12),

            // Timezone Dropdown (Bold header)
            const Text(
              "Timezone",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            DropdownButton<String>(
              value: _selectedTimezone,
              items: _timezones
                  .map((timezone) => DropdownMenuItem<String>(
                        value: timezone,
                        child: Text(timezone),
                      ))
                  .toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedTimezone = newValue!;
                });
              },
              isExpanded: true,
              dropdownColor: Colors.teal.shade50,
              style: const TextStyle(color: Colors.teal),
              iconEnabledColor: Colors.teal,
              underline: Container(),
            ),
            const SizedBox(height: 16),

            // Logout button at the bottom
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Log out and navigate to login page
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginPage()),
                  );
                },
                child: const Text("Logout"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
