import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../firebase_authentication_service.dart';

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
  final AuthService _authService = AuthService();

  bool isSignUpEnabled = false;
  bool isLoading = false;
  bool _obscurePassword = true;
  String fullNameErrorMessage = '';
  String emailErrorMessage = '';
  String passwordErrorMessage = '';
  String phoneErrorMessage = '';
  String generalErrorMessage = '';
  String completePhoneNumber = '';

  bool validateFullName(String value) {
    if (value.isEmpty) {
      fullNameErrorMessage = 'Full name is required.';
      return false;
    } else {
      fullNameErrorMessage = ''; // No error
      return true;
    }
  }

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

  bool validatePhoneNumber(String value) {
    if (value.isEmpty) {
      phoneErrorMessage = 'Phone number is required.';
      return false;
    } else if (!RegExp(r"^\d+$").hasMatch(value)) {
      phoneErrorMessage = 'Phone number must contain only numbers.';
      return false;
    } else {
      phoneErrorMessage = ''; // No error
      return true;
    }
  }

  void validateFields() {
    setState(() {
      bool isFullNameValid = validateFullName(fullNameController.text);
      bool isEmailValid = validateEmail(emailController.text);
      bool isPasswordValid = validatePassword(passwordController.text);
      bool isPhoneValid = validatePhoneNumber(phoneController.text);

      isSignUpEnabled = isFullNameValid &&
          isEmailValid &&
          isPasswordValid &&
          isPhoneValid;
    });
  }

  Future<void> _signUp() async {
    setState(() {
      isLoading = true;
      generalErrorMessage = '';
    });

    try {
      await _authService.signUpWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
        fullName: fullNameController.text.trim(),
        phoneNumber: completePhoneNumber.isNotEmpty
            ? completePhoneNumber
            : phoneController.text.trim(),
      );

      // Navigate to login page on successful signup
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created successfully! Please log in.'),
            backgroundColor: Colors.teal,
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (error) {
      setState(() {
        generalErrorMessage = error.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

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

                // Display general error message if any
                if (generalErrorMessage.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 15),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red.shade300),
                    ),
                    child: Text(
                      generalErrorMessage,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),

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
                    onChanged: (_) => validateFields(),
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
                    onChanged: (phone) {
                      // Save complete phone number with country code
                      completePhoneNumber = phone.completeNumber;
                      validateFields();
                    },
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
                    onChanged: (_) => validateFields(),
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
                    onChanged: (_) => validateFields(),
                  ),
                  errorMessage: passwordErrorMessage,
                ),

                const SizedBox(height: 30),

                // Sign Up Button
                ElevatedButton(
                  onPressed: isSignUpEnabled && !isLoading ? _signUp : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
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
                const SizedBox(height: 30),
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
  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}