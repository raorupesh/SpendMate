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
  String fullNameErrorMessage = '';
  String emailErrorMessage = '';
  String passwordErrorMessage = '';
  String phoneErrorMessage = '';

  // Function to validate full name
  bool validateFullName() {
    if (fullNameController.text.isEmpty) {
      fullNameErrorMessage = 'Full name is required.';
      return false;
    } else {
      fullNameErrorMessage = ''; // No error
      return true;
    }
  }

  // Function to validate email
  bool validateEmail() {
    if (emailController.text.isEmpty) {
      emailErrorMessage = 'Email is required.';
      return false;
    } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(emailController.text)) {
      emailErrorMessage = 'Please enter a valid email.';
      return false;
    } else {
      emailErrorMessage = '';  // No error
      return true;
    }
  }

  // Function to validate password
  bool validatePassword() {
    if (passwordController.text.isEmpty) {
      passwordErrorMessage = 'Password is required.';
      return false;
    } else if (passwordController.text.length < 6) {
      passwordErrorMessage = 'Password must be at least 6 characters.';
      return false;
    } else {
      passwordErrorMessage = '';  // No error
      return true;
    }
  }

  // Function to validate phone number (only numbers)
  bool validatePhoneNumber() {
    if (phoneController.text.isEmpty) {
      phoneErrorMessage = 'Phone number is required.';
      return false;
    } else if (!RegExp(r"^\d+$").hasMatch(phoneController.text)) {  // Ensures only numbers are entered
      phoneErrorMessage = 'Phone number must contain only numbers.';
      return false;
    } else {
      phoneErrorMessage = '';  // No error
      return true;
    }
  }

  // Method to handle field validation
  void validateFields() {
    bool isFullNameValid = validateFullName();
    bool isEmailValid = validateEmail();
    bool isPasswordValid = validatePassword();
    bool isPhoneValid = validatePhoneNumber();

    // Enable sign-up button if all fields are valid
    setState(() {
      isSignUpEnabled = isFullNameValid && isEmailValid && isPasswordValid && isPhoneValid;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, '/login');
        return Future.value(false);
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const SizedBox(height: 50),
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
                  onChanged: (_) {
                    setState(() {
                      validateFields(); // Validate fields
                    });
                  },
                ),
                if (fullNameErrorMessage.isNotEmpty)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        fullNameErrorMessage,
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),
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
                  initialCountryCode: 'US',
                  keyboardType: TextInputType.phone,  // Ensures phone number only accepts numbers
                  onChanged: (phone) {
                    setState(() {
                      validateFields();  // Validate fields
                    });
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
                    setState(() {
                      validateFields(); // Validate fields
                    });
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
                    setState(() {
                      validateFields(); // Validate fields
                    });
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
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                      : null,  // Disable button if fields are not valid
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
