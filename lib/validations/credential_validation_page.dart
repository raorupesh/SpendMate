import 'package:flutter/material.dart';

bool isSignUpEnabled = false;

void validateFields(
    TextEditingController fullNameController,
    TextEditingController emailController,
    TextEditingController passwordController,
    Function updateButtonState, // Use this function to call setState from the widget
    ) {
  final fullName = fullNameController.text;
  final email = emailController.text;
  final password = passwordController.text;

  // Validate fields: full name (not empty), email (valid format), and password (<=20 characters)
  final fullNameValid = fullName.isNotEmpty;
  final emailValid = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email);
  final passwordValid = password.isNotEmpty && password.length <= 20;

  // Call the updateButtonState function to trigger setState in the calling widget
  updateButtonState(() {
    isSignUpEnabled = fullNameValid && emailValid && passwordValid;
  });
}
