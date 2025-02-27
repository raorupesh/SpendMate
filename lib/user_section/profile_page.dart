import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spendmate/providers/shared_prefernce.dart';
import 'login_page.dart'; // Import LoginPage

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isPhoneNumberVisible = false;
  String _selectedTimezone = 'PST';
  String _selectedCurrency = 'USD';
  String? _profileImagePath;
  bool _isImageLoaded = false; // Ensures image is fully loaded

  final List<String> _timezones = ['PST', 'CST', 'EST', 'GMT', 'IST'];
  final List<String> _currencies = ['USD', 'EUR', 'INR', 'GBP', 'AUD'];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  /// **Loads Profile Image & Preferences from SharedPreferences**
  Future<void> _loadProfileData() async {
    final imagePath = await SharedPrefsHelper.getProfileImage();
    final currency = await SharedPrefsHelper.getCurrency() ?? 'USD';
    final timezone = await SharedPrefsHelper.getTimezone() ?? 'PST';

    if (mounted) {
      setState(() {
        _profileImagePath = imagePath;
        _selectedCurrency = currency;
        _selectedTimezone = timezone;
        _isImageLoaded = true; // Ensures UI updates after image loads
      });
    }
  }

  /// **Pick Image and Save Path in SharedPreferences**
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await SharedPrefsHelper.saveProfileImage(pickedFile.path);

      if (mounted) {
        setState(() {
          _profileImagePath = pickedFile.path;
          _isImageLoaded = true; // Update flag after new image selection
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.teal,
      ),
      body: _isImageLoaded
          ? _buildProfileView()
          : const Center(child: CircularProgressIndicator()), // Prevents flicker
    );
  }

  Widget _buildProfileView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          // **Profile Image with Edit Icon**
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 80,
                  backgroundImage: (_profileImagePath != null && File(_profileImagePath!).existsSync())
                      ? FileImage(File(_profileImagePath!))
                      : const AssetImage('assets/images/user_image.png') as ImageProvider,
                  backgroundColor: Colors.grey.shade200,
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

          // **Full Name**
          const Text("Full Name:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text("Spend Mate", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 12),

          // **Email**
          const Text("Email ID:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 4),
          const Text("spendmate@example.com", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 12),

          // **Phone Number**
          const Text("Phone:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Row(
            children: [
              Text(_isPhoneNumberVisible ? "+1 234 567 890" : "**********", style: const TextStyle(fontSize: 16)),
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

          // **Currency Dropdown**
          const Text("Currency", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          DropdownButton<String>(
            value: _selectedCurrency,
            items: _currencies.map((currency) {
              return DropdownMenuItem(value: currency, child: Text(currency));
            }).toList(),
            onChanged: (newValue) async {
              await SharedPrefsHelper.saveCurrency(newValue!);
              setState(() {
                _selectedCurrency = newValue;
              });
            },
            isExpanded: true,
            dropdownColor: Colors.teal.shade50,
            style: const TextStyle(color: Colors.teal),
            iconEnabledColor: Colors.teal,
            underline: Container(),
          ),
          const SizedBox(height: 16),

          // **Timezone Dropdown**
          const Text("Timezone", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          DropdownButton<String>(
            value: _selectedTimezone,
            items: _timezones.map((timezone) {
              return DropdownMenuItem(value: timezone, child: Text(timezone));
            }).toList(),
            onChanged: (newValue) async {
              await SharedPrefsHelper.saveTimezone(newValue!);
              setState(() {
                _selectedTimezone = newValue;
              });
            },
            isExpanded: true,
            dropdownColor: Colors.teal.shade50,
            style: const TextStyle(color: Colors.teal),
            iconEnabledColor: Colors.teal,
            underline: Container(),
          ),
          const SizedBox(height: 16),

          // **Logout Button**
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
    );
  }
}
