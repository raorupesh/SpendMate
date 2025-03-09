import 'package:flutter/material.dart';
import 'package:spendmate/validations/credential_validation_page.dart';
import '../firebase_authentication_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool isLoginEnabled = false;
  bool isLoading = false;
  String emailErrorMessage = '';
  String passwordErrorMessage = '';
  String generalErrorMessage = '';
  bool emailFocused = false;
  bool passwordFocused = false;
  bool _obscurePassword = true;

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

  Future<void> _login() async {
    setState(() {
      isLoading = true;
      generalErrorMessage = '';
    });

    try {
      await _authService.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      // Navigate to home on successful login
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/');
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

  Future<void> _resetPassword() async {
    final String email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        emailErrorMessage = 'Please enter your email to reset password';
      });
      return;
    }

    try {
      await _authService.resetPassword(email);

      // Show confirmation dialog
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password reset email sent to $email'),
            backgroundColor: Colors.teal,
          ),
        );
      }
    } catch (error) {
      setState(() {
        generalErrorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Image.asset(
                      'assets/icons/app_icon.png',
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

                  // Email Input Field
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

                  // Password Input Field
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
                      onPressed: _resetPassword,
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
                      onPressed: isLoginEnabled && !isLoading
                          ? _login
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