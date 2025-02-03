import 'package:flutter/material.dart';
import 'package:spendmate/validations/credential_validation_page.dart'; // Import the shared validation logic

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isSignUpEnabled = false;
  String emailErrorMessage = '';
  String passwordErrorMessage = '';

  // Flags to check if the fields are focused
  bool emailFocused = false;
  bool passwordFocused = false;

  // This method will be called to update the button state
  void updateButtonState(Function callback) {
    setState(() {
      isSignUpEnabled =
          callback(); // We call the callback from validateFields to set the state
    });
  }

  // Function to update the error messages
  void updateErrorMessages(String emailError, String passwordError) {
    setState(() {
      emailErrorMessage = emailError;
      passwordErrorMessage = passwordError;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  validateFields(
                    emailController,
                    passwordController,
                    updateButtonState: updateButtonState,
                    updateErrorMessages: updateErrorMessages,
                    isSignUp: true, // It's sign-up validation
                  );
                },
                onTap: () {
                  setState(() {
                    emailFocused = true; // Mark email field as focused
                  });
                },
              ),
              if (emailFocused && emailErrorMessage.isNotEmpty)
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
                  validateFields(
                    emailController,
                    passwordController,
                    updateButtonState: updateButtonState,
                    updateErrorMessages: updateErrorMessages,
                    isSignUp: true, // It's sign-up validation
                  );
                },
                onTap: () {
                  setState(() {
                    passwordFocused = true; // Mark password field as focused
                  });
                },
              ),
              if (passwordFocused && passwordErrorMessage.isNotEmpty)
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
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
    );
  }
}
