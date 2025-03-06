import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spendmate/providers/shared_prefernce.dart';
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
  bool _isImageLoaded = false;

  final List<String> _timezones = ['PST', 'CST', 'EST', 'GMT', 'IST'];
  final List<String> _currencies = ['USD', 'EUR', 'INR', 'GBP', 'AUD'];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final imagePath = await SharedPrefsHelper.getProfileImage();
    final currency = await SharedPrefsHelper.getCurrency() ?? 'USD';
    final timezone = await SharedPrefsHelper.getTimezone() ?? 'PST';

    if (mounted) {
      setState(() {
        _profileImagePath = imagePath;
        _selectedCurrency = currency;
        _selectedTimezone = timezone;
        _isImageLoaded = true;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await SharedPrefsHelper.saveProfileImage(pickedFile.path);

      if (mounted) {
        setState(() {
          _profileImagePath = pickedFile.path;
          _isImageLoaded = true;
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
          : const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildProfileView() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          Card(
            elevation: 2, // Reduced elevation for a softer look
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
                    title: const Text("Full Name", style: TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: const Text("Spend Mate"),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    title: const Text("Email ID", style: TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: const Text("spendmate@example.com"),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    title: const Text("Phone", style: TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Row(
                      children: [
                        Text(_isPhoneNumberVisible
                            ? "+1 234 567 890"
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
                  const Text("Preferences",
                      style:
                      TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        labelText: "Currency",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                    ),
                    value: _selectedCurrency,
                    items: _currencies.map((currency) {
                      return DropdownMenuItem(
                          value: currency, child: Text(currency));
                    }).toList(),
                    onChanged: (newValue) async {
                      await SharedPrefsHelper.saveCurrency(newValue!);
                      setState(() {
                        _selectedCurrency = newValue;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                        labelText: "Timezone",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8)
                    ),
                    value: _selectedTimezone,
                    items: _timezones.map((timezone) {
                      return DropdownMenuItem(
                          value: timezone, child: Text(timezone));
                    }).toList(),
                    onChanged: (newValue) async {
                      await SharedPrefsHelper.saveTimezone(newValue!);
                      setState(() {
                        _selectedTimezone = newValue;
                      });
                    },
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginPage()),
              );
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