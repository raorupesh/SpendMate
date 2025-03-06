import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

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
  bool _obscurePassword = true;
  String fullNameErrorMessage = '';
  String emailErrorMessage = '';
  String passwordErrorMessage = '';
  String phoneErrorMessage = '';

  bool validateFullName(String value) {
    if (value.isEmpty) {
      fullNameErrorMessage = 'Full name is required.';
      return false;
    } else {
      fullNameErrorMessage = ''; // No error
      return true;
    }
  }

  // Function to validate email
  bool validateEmail(String value) {
    if (value.isEmpty) {
      emailErrorMessage = 'Email is required.';
      return false;
    } else if (!RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
        .hasMatch(value)) {
      emailErrorMessage = 'Please enter a valid email.';
      return false;
    } else {
      emailErrorMessage = ''; // No error
      return true;
    }
  }

  // Function to validate password
  bool validatePassword(String value) {
    if (value.isEmpty) {
      passwordErrorMessage = 'Password is required.';
      return false;
    } else if (value.length < 6) {
      passwordErrorMessage = 'Password must be at least 6 characters.';
      return false;
    } else {
      passwordErrorMessage = ''; // No error
      return true;
    }
  }

  // Function to validate phone number (only numbers)
  bool validatePhoneNumber(String value) {
    if (value.isEmpty) {
      phoneErrorMessage = 'Phone number is required.';
      return false;
    } else if (!RegExp(r"^\d+$").hasMatch(value)) {
      // Ensures only numbers are entered
      phoneErrorMessage = 'Phone number must contain only numbers.';
      return false;
    } else {
      phoneErrorMessage = ''; // No error
      return true;
    }
  }

  // Method to handle field validation
  void validateFields() {
    setState(() {
      // Validate each field
      bool isFullNameValid = validateFullName(fullNameController.text);
      bool isEmailValid = validateEmail(emailController.text);
      bool isPasswordValid = validatePassword(passwordController.text);
      bool isPhoneValid = validatePhoneNumber(phoneController.text);

      // Update sign up button state
      isSignUpEnabled = isFullNameValid &&
          isEmailValid &&
          isPasswordValid &&
          isPhoneValid;
    });
  }

  // Existing validation methods remain the same as in the previous implementation

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.teal.shade600),
          onPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 30),
                Center(
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.teal.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Full Name Input
                _buildInputSection(
                  label: 'Full Name',
                  child: TextField(
                    controller: fullNameController,
                    decoration: _inputDecoration(
                      labelText: 'Enter your full name',
                      prefixIcon: Icons.person_outline,
                    ),
                    keyboardType: TextInputType.name,
                  ),
                  errorMessage: fullNameErrorMessage,
                ),

                // Phone Number Input
                _buildInputSection(
                  label: 'Phone Number',
                  child: IntlPhoneField(
                    controller: phoneController,
                    decoration: _inputDecoration(
                      labelText: 'Enter your phone number',
                      prefixIcon: Icons.phone_outlined,
                    ),
                    initialCountryCode: 'US',
                    keyboardType: TextInputType.phone,
                  ),
                  errorMessage: phoneErrorMessage,
                ),

                // Email Input
                _buildInputSection(
                  label: 'Email',
                  child: TextField(
                    controller: emailController,
                    decoration: _inputDecoration(
                      labelText: 'Enter your email',
                      prefixIcon: Icons.email_outlined,
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                  errorMessage: emailErrorMessage,
                ),

                // Password Input
                _buildInputSection(
                  label: 'Password',
                  child: TextField(
                    controller: passwordController,
                    decoration: _inputDecoration(
                      labelText: 'Enter your password',
                      prefixIcon: Icons.lock_outline,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: Colors.teal.shade600,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    obscureText: _obscurePassword,
                  ),
                  errorMessage: passwordErrorMessage,
                ),

                const SizedBox(height: 30),

                // Sign Up Button
                ElevatedButton(
                  onPressed: isSignUpEnabled
                      ? () {
                    // Add your sign up logic here
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Login redirect
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Colors.black54),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacementNamed(context, '/login'),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          color: Colors.teal.shade600,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method for consistent input decoration
  InputDecoration _inputDecoration({
    required String labelText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.teal.shade600) : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.teal.shade50,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.teal.shade100, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  // Helper method to build input sections with labels and error messages
  Widget _buildInputSection({
    required String label,
    required Widget child,
    required String errorMessage,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        child,
        if (errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12),
            child: Text(
              errorMessage,
              style: TextStyle(color: Colors.red.shade700, fontSize: 12),
            ),
          ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    // Call validateFields after widget initialization
    fullNameController.addListener(validateFields);
    emailController.addListener(validateFields);
    passwordController.addListener(validateFields);
    phoneController.addListener(validateFields);
  }

  @override
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}