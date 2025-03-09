import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spendmate/providers/shared_prefernce.dart';
import 'package:spendmate/firebase_authentication_service.dart';
import 'login_page.dart';

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
  bool _isLoading = true;

  // User data variables
  String _fullName = 'Loading...';
  String _email = 'Loading...';
  String _phoneNumber = 'Loading...';

  final List<String> _timezones = ['PST', 'CST', 'EST', 'GMT', 'IST'];
  final List<String> _currencies = ['USD', 'EUR', 'INR', 'GBP', 'AUD'];

  // Create instance of AuthService
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    try {
      // Load profile preferences
      final imagePath = await SharedPrefsHelper.getProfileImage();
      final currency = await SharedPrefsHelper.getCurrency() ?? 'USD';
      final timezone = await SharedPrefsHelper.getTimezone() ?? 'PST';

      // Load user data from Firestore
      final userData = await _authService.getUserDetails();

      if (mounted) {
        setState(() {
          // Profile preferences
          _profileImagePath = imagePath;
          _selectedCurrency = currency;
          _selectedTimezone = timezone;

          // User data from Firestore
          if (userData != null) {
            _fullName = userData['fullName'] ?? 'User';
            _email = userData['email'] ?? 'example@email.com';
            _phoneNumber = userData['phoneNumber'] ?? '+1 234 567 890';
          } else {
            _fullName = 'No Name Available';
            _email = 'No Email Available';
            _phoneNumber = 'No Phone Available';
          }

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _fullName = 'Error loading data';
          _email = 'Error loading data';
          _phoneNumber = 'Error loading data';
        });
      }
    }
  }

  // Method to reload data - can be called after user edits profile
  Future<void> refreshUserData() async {
    if (mounted) {
      setState(() {
        _isLoading = true;
      });
    }
    await _loadAllData();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await SharedPrefsHelper.saveProfileImage(pickedFile.path);

      if (mounted) {
        setState(() {
          _profileImagePath = pickedFile.path;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with back arrow that navigates to home on tap
      appBar: AppBar(
        title: const Text("Profile"),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: refreshUserData,
            tooltip: 'Refresh Data',
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildProfileView(),
    );
  }

  Widget _buildProfileView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundImage: (_profileImagePath != null &&
                            File(_profileImagePath!).existsSync())
                            ? FileImage(File(_profileImagePath!))
                            : const AssetImage('assets/images/user_image.png')
                        as ImageProvider,
                        backgroundColor: Colors.grey.shade200,
                      ),
                      InkWell(
                        onTap: _pickImage,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.teal,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.edit,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text("Full Name",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(_fullName),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    title: const Text("Email ID",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text(_email),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    title: const Text("Phone",
                        style: TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Row(
                      children: [
                        Text(_isPhoneNumberVisible
                            ? _phoneNumber
                            : "**********"),
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
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Preferences",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Currency",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    value: _selectedCurrency,
                    items: _currencies.map((currency) {
                      return DropdownMenuItem(
                        value: currency,
                        child: Text(currency),
                      );
                    }).toList(),
                    onChanged: (newValue) async {
                      if (newValue != null) {
                        await SharedPrefsHelper.saveCurrency(newValue);
                        await _authService.updateUserProfile(
                          currency: newValue,
                        );
                        setState(() {
                          _selectedCurrency = newValue;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: "Timezone",
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8)),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                    ),
                    value: _selectedTimezone,
                    items: _timezones.map((timezone) {
                      return DropdownMenuItem(
                        value: timezone,
                        child: Text(timezone),
                      );
                    }).toList(),
                    onChanged: (newValue) async {
                      if (newValue != null) {
                        await SharedPrefsHelper.saveTimezone(newValue);
                        await _authService.updateUserProfile(
                          timezone: newValue,
                        );
                        setState(() {
                          _selectedTimezone = newValue;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              await _authService.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              minimumSize: const Size(double.infinity, 50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
            child: const Text("Logout", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
