// ignore_for_file: unused_import
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendmate/main.dart';
import 'package:spendmate/user_section/login_page.dart';
import 'package:spendmate/validations/credential_validation_page.dart';

import '../lib/user_section/profile_page.dart';
import '../lib/user_section/signup_page.dart';

void main() {
  testWidgets('Login button should be enabled/disabled based on input',
      (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Verify the login button is disabled initially
    final loginButton = find.byType(ElevatedButton);
    expect(tester.widget<ElevatedButton>(loginButton).enabled, false);

    // Enter valid email and password
    await tester.enterText(
        find.byType(TextField).at(0), 'test@example.com'); // Email
    await tester.enterText(
        find.byType(TextField).at(1), 'password123'); // Password

    // Trigger a frame after entering text
    await tester.pump();

    // Verify the login button is now enabled
    expect(tester.widget<ElevatedButton>(loginButton).enabled, true);

    // Now, enter invalid email and password (empty password)
    await tester.enterText(find.byType(TextField).at(1), ''); // Password empty
    await tester.pump();

    // Verify the login button is still disabled
    expect(tester.widget<ElevatedButton>(loginButton).enabled, false);
  });

  testWidgets('Login button should be enabled/disabled based on user input',
      (WidgetTester tester) async {
    // Build the LoginPage widget and trigger a frame
    await tester.pumpWidget(const MaterialApp(home: LoginPage()));

    // Find the TextField widgets for email and password
    final emailField = find.byType(TextField).at(0); // First TextField is email
    final passwordField =
        find.byType(TextField).at(1); // Second TextField is password

    // Find the Login button
    final loginButton = find.byType(ElevatedButton);

    // Initially, verify that the login button is disabled
    expect(tester.widget<ElevatedButton>(loginButton).enabled, false);

    // Enter valid email and password
    await tester.enterText(emailField, 'test@example.com'); // Email
    await tester.enterText(passwordField, 'password123'); // Password

    // Trigger a frame to rebuild the widget after entering text
    await tester.pump();

    // Verify that the login button is now enabled
    expect(tester.widget<ElevatedButton>(loginButton).enabled, true);

    // Now, leave the password field empty and verify that the login button is disabled again
    await tester.enterText(passwordField, ''); // Empty password
    await tester.pump();

    // Verify that the login button is still disabled
    expect(tester.widget<ElevatedButton>(loginButton).enabled, false);
  });

  group('SignUpPage Unit Tests', () {
    test('Full Name Validation - should return error when empty', () {
      final signUpPage = SignUpPage();
      final state =
          signUpPage.createState(); // Create the state from SignUpPage

      state.fullNameController.text = '';
      expect(state.validateFullName(), false);
      expect(state.fullNameErrorMessage, 'Full name is required.');
    });

    test('Full Name Validation - should pass when not empty', () {
      final signUpPage = SignUpPage();
      final state =
          signUpPage.createState(); // Create the state from SignUpPage

      state.fullNameController.text = 'John Doe';
      expect(state.validateFullName(), true);
      expect(state.fullNameErrorMessage, '');
    });

    test('Email Validation - should return error when empty', () {
      final signUpPage = SignUpPage();
      final state =
          signUpPage.createState(); // Create the state from SignUpPage

      state.emailController.text = '';
      expect(state.validateEmail(), false);
      expect(state.emailErrorMessage, 'Email is required.');
    });

    test('Email Validation - should return error for invalid email', () {
      final signUpPage = SignUpPage();
      final state =
          signUpPage.createState(); // Create the state from SignUpPage

      state.emailController.text = 'invalid-email';
      expect(state.validateEmail(), false);
      expect(state.emailErrorMessage, 'Please enter a valid email.');
    });

    test('Email Validation - should pass for valid email', () {
      final signUpPage = SignUpPage();
      final state =
          signUpPage.createState(); // Create the state from SignUpPage

      state.emailController.text = 'test@example.com';
      expect(state.validateEmail(), true);
      expect(state.emailErrorMessage, '');
    });

    test('Password Validation - should return error when empty', () {
      final signUpPage = SignUpPage();
      final state =
          signUpPage.createState(); // Create the state from SignUpPage

      state.passwordController.text = '';
      expect(state.validatePassword(), false);
      expect(state.passwordErrorMessage, 'Password is required.');
    });

    test('Password Validation - should return error for short password', () {
      final signUpPage = SignUpPage();
      final state =
          signUpPage.createState(); // Create the state from SignUpPage

      state.passwordController.text = '12345';
      expect(state.validatePassword(), false);
      expect(state.passwordErrorMessage,
          'Password must be at least 6 characters.');
    });

    test('Password Validation - should pass for valid password', () {
      final signUpPage = SignUpPage();
      final state =
          signUpPage.createState(); // Create the state from SignUpPage

      state.passwordController.text = 'password123';
      expect(state.validatePassword(), true);
      expect(state.passwordErrorMessage, '');
    });

    test('Phone Validation - should return error when empty', () {
      final signUpPage = SignUpPage();
      final state =
          signUpPage.createState(); // Create the state from SignUpPage

      state.phoneController.text = '';
      expect(state.validatePhoneNumber(), false);
      expect(state.phoneErrorMessage, 'Phone number is required.');
    });

    test('Phone Validation - should return error for non-numeric input', () {
      final signUpPage = SignUpPage();
      final state =
          signUpPage.createState(); // Create the state from SignUpPage

      state.phoneController.text = 'abc123';
      expect(state.validatePhoneNumber(), false);
      expect(
          state.phoneErrorMessage, 'Phone number must contain only numbers.');
    });

    test('Phone Validation - should pass for valid phone number', () {
      final signUpPage = SignUpPage();
      final state =
          signUpPage.createState(); // Create the state from SignUpPage

      state.phoneController.text = '1234567890';
      expect(state.validatePhoneNumber(), true);
      expect(state.phoneErrorMessage, '');
    });

    group('ProfilePage Tests', () {
      // Test 1: Phone number visibility toggles
      testWidgets('Phone number visibility toggles when icon is pressed',
          (WidgetTester tester) async {
        // Build the ProfilePage widget
        await tester.pumpWidget(MaterialApp(home: ProfilePage()));

        // Initially, the phone number should be hidden
        expect(find.text('**********'), findsOneWidget);
        expect(find.text('+1 234 567 890'), findsNothing);

        // Tap the visibility icon to show the phone number
        await tester.tap(find.byIcon(Icons.visibility_off));
        await tester.pump();

        // Now, the phone number should be visible
        expect(find.text('**********'), findsNothing);
        expect(find.text('+1 234 567 890'), findsOneWidget);

        // Tap the visibility icon again to hide the phone number
        await tester.tap(find.byIcon(Icons.visibility));
        await tester.pump();

        // The phone number should now be hidden again
        expect(find.text('**********'), findsOneWidget);
        expect(find.text('+1 234 567 890'), findsNothing);
      });
    });
  });
}
