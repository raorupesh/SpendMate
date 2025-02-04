import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // To prevent back navigation
import 'package:spendmate/validations/credential_validation_page.dart'; // Import the shared validation logic

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();

  bool isLoginEnabled = false;
  String emailErrorMessage = '';
  String passwordErrorMessage = '';
  bool emailFocused = false; // To track if the email field is interacted with
  bool passwordFocused = false; // To track if the password field is interacted with

  // This function is used to trigger setState and update the login button state
  void updateButtonState(Function callback) {
    setState(() {
      isLoginEnabled = callback(); // We call the callback from validateFields to set the state
    });
  }

  // Function to update the error messages
  void updateErrorMessages(String emailError, String passwordError) {
    setState(() {
      emailErrorMessage = emailError;
      passwordErrorMessage = passwordError;
    });
  }

  // Method to handle back navigation (prevent going back to previous pages)
  Future<bool> _onWillPop() async {
    // Disable back button press
    return Future.value(false); // This prevents the back navigation
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Prevent back navigation
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const SizedBox(height: 30),
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
                    onChanged: (_) {
                      validateFields(
                        emailController,
                        passwordController,
                        updateButtonState: updateButtonState,
                        updateErrorMessages: updateErrorMessages,
                        isSignUp: false, // It's login, not sign-up
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
                    onChanged: (_) {
                      validateFields(
                        emailController,
                        passwordController,
                        updateButtonState: updateButtonState,
                        updateErrorMessages: updateErrorMessages,
                        isSignUp: false, // It's login, not sign-up
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
                  const SizedBox(height: 30),

                  // Login Button
                  ElevatedButton(
                    onPressed: isLoginEnabled
                        ? () {
                      Navigator.pushReplacementNamed(
                          context, '/'); // Navigate to the home page
                    }
                        : null,
                    // Disable the button if fields are empty or invalid
                    child: const Text('Login'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade300,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                      textStyle:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Sign-Up Button
                  TextButton(
                    onPressed: () {
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
      ),
    );
  }
}
