import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spendmate/user_section/login_page.dart';
import 'package:spendmate/user_section/profile_page.dart';
import 'package:spendmate/user_section/signup_page.dart';
import 'package:spendmate/groups/group_details_page.dart';

import 'package:spendmate/groups/add_group_members_page.dart';
import 'package:spendmate/groups/group_settings_page.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/providers/transaction_provider.dart';


void main() {
  // Group tests for LoginPage
  group('LoginPage Tests', () {
    testWidgets('Login button should be disabled initially and enabled with valid input',
            (WidgetTester tester) async {
          // Build the LoginPage widget and trigger a frame
          await tester.pumpWidget(const MaterialApp(home: LoginPage()));

          // Verify the login button is disabled initially
          final loginButton = find.byType(ElevatedButton);
          expect(tester.widget<ElevatedButton>(loginButton).enabled, false);

          // Enter valid email and password
          await tester.enterText(find.byType(TextField).at(0), 'test@example.com'); // Email
          await tester.enterText(find.byType(TextField).at(1), 'password123'); // Password

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

    testWidgets('Login button should toggle (disable/enable) based on password input',
            (WidgetTester tester) async {
          // Build the LoginPage widget and trigger a frame
          await tester.pumpWidget(const MaterialApp(home: LoginPage()));

          // Find the TextField widgets for email and password
          final emailField = find.byType(TextField).at(0); // First TextField is email
          final passwordField = find.byType(TextField).at(1); // Second TextField is password

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
  });

  // Group tests for SignUpPage
  group('SignUpPage Tests', () {
    test('Full Name Validation - should return error when empty', () {
      final signUpPage = SignUpPage();
      final state = signUpPage.createState(); // Create the state from SignUpPage

      state.fullNameController.text = '';
      expect(state.validateFullName(), false);
      expect(state.fullNameErrorMessage, 'Full name is required.');
    });

    test('Full Name Validation - should pass when not empty', () {
      final signUpPage = SignUpPage();
      final state = signUpPage.createState(); // Create the state from SignUpPage

      state.fullNameController.text = 'John Doe';
      expect(state.validateFullName(), true);
      expect(state.fullNameErrorMessage, '');
    });

    test('Email Validation - should return error when empty', () {
      final signUpPage = SignUpPage();
      final state = signUpPage.createState(); // Create the state from SignUpPage

      state.emailController.text = '';
      expect(state.validateEmail(), false);
      expect(state.emailErrorMessage, 'Email is required.');
    });

    test('Email Validation - should return error for invalid email', () {
      final signUpPage = SignUpPage();
      final state = signUpPage.createState(); // Create the state from SignUpPage

      state.emailController.text = 'invalid-email';
      expect(state.validateEmail(), false);
      expect(state.emailErrorMessage, 'Please enter a valid email.');
    });

    test('Email Validation - should pass for valid email', () {
      final signUpPage = SignUpPage();
      final state = signUpPage.createState(); // Create the state from SignUpPage

      state.emailController.text = 'test@example.com';
      expect(state.validateEmail(), true);
      expect(state.emailErrorMessage, '');
    });

    test('Password Validation - should return error when empty', () {
      final signUpPage = SignUpPage();
      final state = signUpPage.createState(); // Create the state from SignUpPage

      state.passwordController.text = '';
      expect(state.validatePassword(), false);
      expect(state.passwordErrorMessage, 'Password is required.');
    });

    test('Password Validation - should return error for short password', () {
      final signUpPage = SignUpPage();
      final state = signUpPage.createState(); // Create the state from SignUpPage

      state.passwordController.text = '12345';
      expect(state.validatePassword(), false);
      expect(state.passwordErrorMessage, 'Password must be at least 6 characters.');
    });

    test('Password Validation - should pass for valid password', () {
      final signUpPage = SignUpPage();
      final state = signUpPage.createState(); // Create the state from SignUpPage

      state.passwordController.text = 'password123';
      expect(state.validatePassword(), true);
      expect(state.passwordErrorMessage, '');
    });

    test('Phone Validation - should return error when empty', () {
      final signUpPage = SignUpPage();
      final state = signUpPage.createState(); // Create the state from SignUpPage

      state.phoneController.text = '';
      expect(state.validatePhoneNumber(), false);
      expect(state.phoneErrorMessage, 'Phone number is required.');
    });

    test('Phone Validation - should return error for non-numeric input', () {
      final signUpPage = SignUpPage();
      final state = signUpPage.createState(); // Create the state from SignUpPage

      state.phoneController.text = 'abc123';
      expect(state.validatePhoneNumber(), false);
      expect(state.phoneErrorMessage, 'Phone number must contain only numbers.');
    });

    test('Phone Validation - should pass for valid phone number', () {
      final signUpPage = SignUpPage();
      final state = signUpPage.createState(); // Create the state from SignUpPage

      state.phoneController.text = '1234567890';
      expect(state.validatePhoneNumber(), true);
      expect(state.phoneErrorMessage, '');
    });
  });

  // Group tests for ProfilePage
  group('ProfilePage Tests', () {

    // Test 1: Phone number visibility toggles when icon is pressed
    testWidgets('Phone number visibility toggles when icon is pressed', (WidgetTester tester) async {
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
    // Test 2: Currency selection from dropdown
    testWidgets('Currency selection from dropdown', (WidgetTester tester) async {
      // Build the ProfilePage widget
      await tester.pumpWidget(MaterialApp(home: ProfilePage()));

      // Open the currency dropdown
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Select a currency (for example, "USD")
      await tester.tap(find.text('INR').last);  // Use .last in case there are multiple 'USD' options
      await tester.pumpAndSettle();

      // Verify that the selected currency is displayed
      expect(find.text('INR'), findsOneWidget); // Assuming the dropdown displays the selected value
    });
    group('GroupSettingsPage Tests', () {
      testWidgets('Should display members and allow modification', (WidgetTester tester) async {
        // List of initial group members
        final members = ['Vamshi', 'Karthik', 'Nandan'];

        // Initialize GroupSettingsPage with the list of members
        await tester.pumpWidget(MaterialApp(
          home: GroupSettingsPage(groupName: 'New Group', groupMembers: members),
        ));

        // Verify that all members are listed
        expect(find.text('Vamshi'), findsOneWidget);
        expect(find.text('Karthik'), findsOneWidget);
        expect(find.text('Nandan'), findsOneWidget);

        // Tap to modify members
        await tester.tap(find.text('Modify Members'));
        await tester.pumpAndSettle();

        // Simulate adding/removing members
        await tester.tap(find.text('Moin'));
        await tester.pumpAndSettle();

        // Verify that the modified members are shown
        expect(find.text('Moin'), findsOneWidget);
      });

      testWidgets('Should prompt to confirm leaving the group', (WidgetTester tester) async {
        // List of initial group members
        final members = ['Vamshi', 'Karthik', 'Nandan'];

        // Initialize GroupSettingsPage with the list of members
        await tester.pumpWidget(MaterialApp(
          home: GroupSettingsPage(groupName: 'New Group', groupMembers: members),
        ));

        // Tap to leave the group
        await tester.tap(find.text('Leave Group'));
        await tester.pumpAndSettle();

        // Verify that the confirmation dialog is shown
        expect(find.text('Are you sure you want to leave this group?'), findsOneWidget);
      });
    });

    group('GroupDetailPage Tests', () {
      testWidgets('Should show the Group Settings page when settings icon is tapped', (WidgetTester tester) async {
        // Simulate a group with no transactions
        final groupProvider = GroupProvider();
        groupProvider.addGroup(Group(name: 'New Group', members: ['Vamshi'], transactions: []));

        await tester.pumpWidget(
          ChangeNotifierProvider(
            create: (context) => groupProvider,
            child: MaterialApp(home: GroupDetailPage(groupName: 'New Group')),
          ),
        );

        // Tap on the settings icon to navigate to GroupSettingsPage
        await tester.tap(find.byIcon(Icons.settings));
        await tester.pumpAndSettle();

        // Verify that we navigated to the GroupSettingsPage
        expect(find.text('Group Settings'), findsOneWidget);
      });
    });

  });

  // Group tests for Add Group Members Page
  group('AddGroupMembersPage Tests', () {
    testWidgets('Should display friend list and allow selection', (WidgetTester tester) async {
      // Initial list of preselected friends is empty
      await tester.pumpWidget(const MaterialApp(
        home: AddGroupMembersPage(preselectedFriends: []),
      ));

      // Verify that the list of friends is visible
      expect(find.text('Vamshi'), findsOneWidget);
      expect(find.text('Karthik'), findsOneWidget);

      // Select a friend (for example, "Vamshi")
      await tester.tap(find.byType(CheckboxListTile).first);
      await tester.pumpAndSettle();

      // Verify that the friend is selected
      expect(find.byType(CheckboxListTile), findsWidgets);
    });
// Group tests for Add Group Members Page
    group('AddGroupMembersPage Tests', () {
      testWidgets('Should display friend list and allow selection', (WidgetTester tester) async {
        // Initial list of preselected friends is empty
        await tester.pumpWidget(const MaterialApp(
          home: AddGroupMembersPage(preselectedFriends: []),
        ));

        // Verify that the list of friends is visible
        expect(find.text('Vamshi'), findsOneWidget);
        expect(find.text('Karthik'), findsOneWidget);

        // Select a friend (for example, "Vamshi")
        await tester.tap(find.byType(CheckboxListTile).first);
        await tester.pumpAndSettle();

        // Verify that the friend is selected
        expect(find.byType(CheckboxListTile), findsWidgets);
      });

      // Group tests for Add Group Members Page
      group('Add Group MembersPage Tests', () {
        testWidgets('Should display friend list and allow selection', (WidgetTester tester) async {
          // Initial list of preselected friends is empty
          await tester.pumpWidget(const MaterialApp(
            home: AddGroupMembersPage(preselectedFriends: []),
          ));

          // Verify that the list of friends is visible
          expect(find.text('Vamshi'), findsOneWidget);
          expect(find.text('Karthik'), findsOneWidget);

          // Select a friend (for example, "Vamshi")
          await tester.tap(find.byType(CheckboxListTile).first);
          await tester.pumpAndSettle();

          // Verify that the friend is selected
          expect(find.byType(CheckboxListTile), findsWidgets);
        });

        testWidgets('Should allow creating a new group and redirect to group page', (WidgetTester tester) async {
          // Simulate the AddGroupMembersPage with preselected friends
          List<String> preselectedFriends = ['Vamshi', 'Karthik'];

          // Create the widget to test
          await tester.pumpWidget(MaterialApp(
            home: AddGroupMembersPage(preselectedFriends: preselectedFriends),
          ));

          // Verify that the friends are listed
          expect(find.text('Vamshi'), findsOneWidget);
          expect(find.text('Karthik'), findsOneWidget);

          // Select a friend (for example, "Karthik") to add to the group
          await tester.tap(find.byType(CheckboxListTile).at(1)); // Select "Karthik"
          await tester.pumpAndSettle();

          // Ensure the UI has settled, especially if there are animations or state changes
          await tester.pumpAndSettle();

          // Check that the "Create" button exists before tapping it
          expect(find.text('Create'), findsOneWidget);  // Expect the button with text 'Create'

          // Tap on the "Create" button
          await tester.tap(find.text('Create').first);  // Tapping the button with the name 'Create'
          await tester.pumpAndSettle();

          // Verify redirection to the Group Page
          // Check for an element that identifies the Group Page after navigation (e.g., group name or some unique widget in the group page)
          expect(find.text('Group Name'), findsOneWidget);  // Check for a widget that identifies the group page

          // Optionally, verify that selected members are displayed in the group page
          expect(find.text('Vamshi'), findsOneWidget);  // Check that the members selected are shown
          expect(find.text('Karthik'), findsOneWidget);  // Check that the members selected are shown
        });



      });

    });

  });


}
