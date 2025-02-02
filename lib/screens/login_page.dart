import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoginEnabled = false;

  // Method to validate if both fields are filled
  void validateFields() {
    setState(() {
      isLoginEnabled = emailController.text.isNotEmpty && passwordController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(  // This centers the entire body content vertically and horizontally
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,  // Center the column content vertically
              crossAxisAlignment: CrossAxisAlignment.center, // Center the column content horizontally
              children: <Widget>[
                const SizedBox(height: 30),
                // Logo or App Name
                Center(
                  child: Text(
                    'SpendMate',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 40),

                // Email Input Field
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.teal.shade700),
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  style: TextStyle(color: Colors.teal.shade900),
                  onChanged: (_) => validateFields(),  // Validate when the text changes
                ),
                const SizedBox(height: 20),

                // Password Input Field
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    labelStyle: TextStyle(color: Colors.teal.shade700),
                    filled: true,
                    fillColor: Colors.teal.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  obscureText: true,
                  style: TextStyle(color: Colors.teal.shade900),
                  onChanged: (_) => validateFields(),  // Validate when the text changes
                ),
                const SizedBox(height: 30),

                // Login Button
                ElevatedButton(
                  onPressed: isLoginEnabled
                      ? () {
                    // After login, navigate to the home page and remove the login page from the stack
                    Navigator.pushReplacementNamed(context, '/'); // Home page
                  }
                      : null, // Disable the button if fields are empty
                  child: const Text('Login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade300,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),

                // Sign-Up Button
                TextButton(
                  onPressed: () {
                    // When clicking "Don't have an account?", navigate to the sign-up page and remove the login page from the stack
                    Navigator.pushReplacementNamed(context, '/signup');
                  },
                  child: const Text(
                    'Don\'t have an account? Sign Up',
                    style: TextStyle(color: Colors.teal, fontSize: 16),
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
