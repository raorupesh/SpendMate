import 'dart:async';
import 'package:flutter/material.dart';
import '../firebase_authentication_service.dart';
import 'login_page.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isLoading = false;
  String errorMessage = '';
  String successMessage = '';
  bool isButtonDisabled = false;
  Timer? _timer;
  int secondsRemaining = 60;

  Future<void> _resetPassword() async {
    final String email = emailController.text.trim();

    if (email.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your registered email.';
        successMessage = '';
      });
      return;
    }

    setState(() {
      isLoading = true;
      isButtonDisabled = true;
      errorMessage = '';
      successMessage = '';
      secondsRemaining = 60; // Reset timer
    });

    try {
      await _authService.resetPassword(email);
      setState(() {
        successMessage =
        'Password reset link has been sent to your email. Please check and reset your password.';
      });

      // Start the 1-minute cooldown timer
      _startCooldownTimer();
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isButtonDisabled = false; // Enable button if error occurs
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _startCooldownTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining > 0) {
        setState(() {
          secondsRemaining--;
        });
      } else {
        setState(() {
          isButtonDisabled = false;
          timer.cancel();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
                context, MaterialPageRoute(builder: (context) => const LoginPage()));
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Enter your registered email to receive a password reset link:',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 20),
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 14),
              ),
            if (successMessage.isNotEmpty)
              Text(
                successMessage,
                style: const TextStyle(color: Colors.green, fontSize: 14),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isButtonDisabled ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: isButtonDisabled ? Colors.grey : Colors.teal,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                ),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                isButtonDisabled
                    ? 'Wait $secondsRemaining sec'
                    : 'Continue',
                style: const TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                    context, MaterialPageRoute(builder: (context) => const LoginPage()));
              },
              child: const Text('Back to Login'),
            ),
          ],
        ),
      ),
    );
  }
}
