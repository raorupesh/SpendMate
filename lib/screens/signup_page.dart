import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart'; // For phone number input with country code

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool isSignUpEnabled = false;
  String emailErrorMessage = '';
  String passwordErrorMessage = '';
  String phoneErrorMessage = '';  // Error message for phone number

  // Flags to check if the fields are focused
  bool emailFocused = false;
  bool passwordFocused = false;
  bool phoneFocused = false;  // Flag for phone number field

  // Method to handle back navigation
  Future<bool> _onBackPressed() async {
    Navigator.pushReplacementNamed(context, '/login');
    return Future.value(false);  // Prevent default back navigation
  }

  // Function to validate phone number
  bool validatePhoneNumber() {
    if (phoneController.text.isEmpty) {
      phoneErrorMessage = "Phone number is required.";
      return false;
    } else {
      phoneErrorMessage = '';  // No error
      return true;
    }
  }

  // Method to handle field validation
  bool validateFields() {
    String emailError = '';
    String passwordError = '';
    String phoneError = '';

    // Email validation: Ensure email is not empty and follows a basic pattern
    bool isEmailValid = emailController.text.isNotEmpty && RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(emailController.text);
    if (!isEmailValid) {
      emailError = "Please enter a valid email.";
    }

    // Password validation: Ensure password is at least 6 characters
    bool isPasswordValid = passwordController.text.length >= 6;
    if (!isPasswordValid) {
      passwordError = "Password must be at least 6 characters.";
    }

    // Phone number validation: Ensure phone number is not empty
    bool isPhoneValid = validatePhoneNumber();
    if (!isPhoneValid) {
      phoneError = phoneErrorMessage;
    }

    // Update error messages
    setState(() {
      emailErrorMessage = emailError;
      passwordErrorMessage = passwordError;
      phoneErrorMessage = phoneError;
    });

    // Enable sign-up button if all fields are valid
    setState(() {
      isSignUpEnabled = isEmailValid && isPasswordValid && isPhoneValid;
    });

    // Return true if all fields are valid
    return isEmailValid && isPasswordValid && isPhoneValid;
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,  // Intercept back button press
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 50),
                // Title: Sign Up
                Center(
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 50),

                // Full Name Input Field
                const Text(
                  'Full Name',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: fullNameController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    labelText: 'Enter your full name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.name,
                ),
                const SizedBox(height: 16),

                // Phone Number Input Field with Country Code
                const Text(
                  'Phone Number',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                IntlPhoneField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Enter your phone number',
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  initialCountryCode: 'US',  // You can change the default country code
                  onChanged: (phone) {
                    validateFields(); // Validate fields whenever phone number is changed
                  },
                ),
                if (phoneErrorMessage.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        phoneErrorMessage,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Email Input Field
                const Text(
                  'Email',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    labelText: 'Enter your email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) {
                    validateFields(); // Validate fields whenever email is changed
                  },
                ),
                if (emailErrorMessage.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        emailErrorMessage,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),

                // Password Input Field
                const Text(
                  'Password',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    labelText: 'Enter your password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: true,
                  onChanged: (_) {
                    validateFields(); // Validate fields whenever password is changed
                  },
                ),
                if (passwordErrorMessage.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        passwordErrorMessage,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),

                // Sign Up Button (Only enabled when valid)
                ElevatedButton(
                  onPressed: isSignUpEnabled
                      ? () {
                    // After successful sign-up, redirect to Login Page
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                      : null, // Disable button if fields are not valid
                  child: const Text('Sign Up'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    backgroundColor: Colors.teal.shade500,
                    textStyle: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
