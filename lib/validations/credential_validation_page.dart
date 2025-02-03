import 'package:flutter/material.dart';

void validateFields(
  TextEditingController emailController,
  TextEditingController passwordController, {
  required Function updateButtonState,
  required Function updateErrorMessages,
  required bool isSignUp,
}) {
  String emailError = '';
  String passwordError = '';

  if (emailController.text.isEmpty) {
    emailError = 'Email cannot be empty';
  } else if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
      .hasMatch(emailController.text)) {
    emailError = 'Invalid email address';
  }

  if (passwordController.text.isEmpty) {
    passwordError = 'Password cannot be empty';
  } else if (passwordController.text.length < 6) {
    passwordError = 'Password must be at least 6 characters';
  }

  // Update the error messages (only email and password for login)
  updateErrorMessages(emailError, passwordError);

  // Check if the form is valid
  updateButtonState(() {
    return emailError.isEmpty && passwordError.isEmpty;
  });
}
