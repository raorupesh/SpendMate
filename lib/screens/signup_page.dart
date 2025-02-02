import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../validations/credential_validation_page.dart'; // Import the validation logic

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Controllers for each field
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // This method will be called to update the button state
  void updateButtonState(Function setStateCallback) {
    setState(() {
      setStateCallback();
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
              const SizedBox(height: 50), // Add some space before the fields

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
                inputFormatters: [
                  LengthLimitingTextInputFormatter(100),
                ],
                onChanged: (_) {
                  // Call validation function when field value changes
                  validateFields(fullNameController, emailController, passwordController, updateButtonState);
                },
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
                inputFormatters: [
                  LengthLimitingTextInputFormatter(100),
                ],
                onChanged: (_) {
                  // Call validation function when field value changes
                  validateFields(fullNameController, emailController, passwordController, updateButtonState);
                },
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
                keyboardType: TextInputType.visiblePassword,
                inputFormatters: [
                  LengthLimitingTextInputFormatter(20),
                ],
                onChanged: (_) {
                  // Call validation function when field value changes
                  validateFields(fullNameController, emailController, passwordController, updateButtonState);
                },
              ),
              const SizedBox(height: 20),

              // Sign Up Button (Only enabled when valid)
              ElevatedButton(
                onPressed: isSignUpEnabled
                    ? () {
                  // After successful sign up, redirect to Login Page
                  Navigator.pushReplacementNamed(context, '/login');
                }
                    : null, // Disable button if fields are not valid
                child: const Text('Sign Up'),

                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  backgroundColor: Colors.teal.shade500,
                  textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),

              const SizedBox(height: 20),

              // Terms and Conditions Disclaimer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'By signing up, you accept our ',
                    style: TextStyle(fontSize: 14),
                  ),
                  GestureDetector(
                    onTap: () {
                      // Open Terms and Conditions (You can implement this feature if needed)
                      print('Terms and Conditions tapped');
                    },
                    child: const Text(
                      'Terms and Conditions',
                      style: TextStyle(fontSize: 14, color: Colors.teal, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Link to Login Page
              Center(
                child: TextButton(
                  onPressed: () {
                    // If user clicks 'Already have an account?', navigate to login
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  child: const Text('Already have an account? Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
