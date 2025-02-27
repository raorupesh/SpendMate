import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';


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
  String? _profileImagePath; // Store profile image path

  final List<String> _timezones = ['PST', 'CST', 'EST', 'GMT', 'IST'];
  final List<String> _currencies = ['USD', 'EUR', 'INR', 'GBP', 'AUD'];

  @override
  void initState() {
    super.initState();
    _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _profileImagePath = prefs.getString('profile_image');
    });
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImagePath = pickedFile.path;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', pickedFile.path);
    }
  }

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
            // Profile Image with Edit Icon
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 80,
                    backgroundImage: _profileImagePath != null
                        ? FileImage(File(_profileImagePath!))
                        : const AssetImage('assets/images/user_image.png') as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.teal,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: const Icon(Icons.edit, color: Colors.white, size: 24),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Full Name
            const Text(
              "Full Name:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text("Spend Mate", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),

            // Email
            const Text(
              "Email ID:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 4),
            const Text("spendmate@example.com", style: TextStyle(fontSize: 16)),
            const SizedBox(height: 12),

            // Phone Number
            const Text(
              "Phone:",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Row(
              children: [
                Text(
                  _isPhoneNumberVisible ? "+1 234 567 890" : "**********",
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: Icon(
                    _isPhoneNumberVisible ? Icons.visibility : Icons.visibility_off,
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

            // Currency Dropdown
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

            // Timezone Dropdown
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

            // Logout Button
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: ElevatedButton(
                onPressed: () {
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
