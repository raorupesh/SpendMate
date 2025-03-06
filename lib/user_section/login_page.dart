import 'package:flutter/material.dart';
import 'package:spendmate/validations/credential_validation_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isLoginEnabled = false;
  String emailErrorMessage = '';
  String passwordErrorMessage = '';
  bool emailFocused = false;
  bool passwordFocused = false;
  bool _obscurePassword = true; // Added to toggle password visibility

  void updateButtonState(Function callback) {
    setState(() {
      isLoginEnabled = callback();
    });
  }

  void updateErrorMessages(String emailError, String passwordError) {
    setState(() {
      emailErrorMessage = emailError;
      passwordErrorMessage = passwordError;
    });
  }

  Future<bool> _onWillPop() async => Future.value(false);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white, // Changed background color
        body: SafeArea( // Added SafeArea for better device compatibility
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Image.asset(
                      'assets/icons/app_icon.png', // Update with your actual asset path
                      width: 120,
                      height: 120,
                    ),
                  ),
                  const SizedBox(height: 30),

                  Text(
                    'Welcome Back!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal.shade800,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Email Input Field with Enhanced Design
                  _buildInputField(
                    controller: emailController,
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    errorMessage: emailErrorMessage,
                    isFocused: emailFocused,
                    onChanged: (_) => validateFields(
                      emailController,
                      passwordController,
                      updateButtonState: updateButtonState,
                      updateErrorMessages: updateErrorMessages,
                      isSignUp: false,
                    ),
                    onTap: () => setState(() => emailFocused = true),
                  ),
                  const SizedBox(height: 16),

                  // Password Input Field with Visibility Toggle
                  _buildInputField(
                    controller: passwordController,
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    obscureText: _obscurePassword,
                    errorMessage: passwordErrorMessage,
                    isFocused: passwordFocused,
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
                    onChanged: (_) => validateFields(
                      emailController,
                      passwordController,
                      updateButtonState: updateButtonState,
                      updateErrorMessages: updateErrorMessages,
                      isSignUp: false,
                    ),
                    onTap: () => setState(() => passwordFocused = true),
                  ),

                  // Forgot Password Link
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password functionality
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(
                          color: Colors.teal.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login Button with Gradient and Elevation
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.teal.shade400,
                          Colors.teal.shade600,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.teal.shade200,
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: isLoginEnabled
                          ? () {
                        Navigator.pushReplacementNamed(context, '/');
                      }
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)
                        ),
                      ),
                      child: Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Divider with "or" text
                  Row(
                    children: [
                      Expanded(child: Divider(color: Colors.teal.shade200)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'or',
                          style: TextStyle(color: Colors.teal.shade600),
                        ),
                      ),
                      Expanded(child: Divider(color: Colors.teal.shade200)),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Sign-Up Navigation
                  Center(
                    child: TextButton(
                      onPressed: () {
                        // Navigate to the sign-up page
                        Navigator.pushReplacementNamed(context, '/signup');
                      },
                      child: RichText(
                        text: TextSpan(
                          text: 'Don\'t have an account? ',
                          style: TextStyle(color: Colors.teal.shade700),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: TextStyle(
                                color: Colors.teal.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
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

  // Custom Input Field Widget
  Widget _buildInputField({
    required TextEditingController controller,
    required String labelText,
    String hintText = '',
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String errorMessage = '',
    bool isFocused = false,
    Widget? suffixIcon,
    Function(String)? onChanged,
    Function()? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: labelText,
            hintText: hintText,
            labelStyle: TextStyle(color: Colors.teal.shade700),
            hintStyle: TextStyle(color: Colors.teal.shade300),
            filled: true,
            fillColor: Colors.teal.shade50,
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.teal.shade600, width: 2),
            ),
          ),
          keyboardType: keyboardType,
          obscureText: obscureText,
          style: TextStyle(color: Colors.teal.shade900),
          onChanged: onChanged,
          onTap: onTap,
        ),
        if (isFocused && errorMessage.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 12),
            child: Text(
              errorMessage,
              style: TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}