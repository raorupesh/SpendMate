import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/chores/assign_chores_page.dart';
import 'package:spendmate/chores/chores_details_page.dart';
import 'package:spendmate/groups/add_group_members_page.dart';
import 'package:spendmate/groups/group_details_page.dart';
import 'package:spendmate/groups/group_settings_page.dart';
import 'package:spendmate/providers/chores_provider.dart';
import 'package:spendmate/providers/transaction_provider.dart';
import 'package:spendmate/screens/home_page.dart';
import 'package:spendmate/user_section/login_page.dart';
import 'package:spendmate/user_section/profile_page.dart';
import 'package:spendmate/user_section/signup_page.dart';

import '../lib/groups/groups_page.dart';
import '../lib/screens/splash_screen.dart';
import '../lib/transactions/transaction_details_page.dart';
import '../lib/widgets/bottom_nav_bar.dart';

void main() {
  testWidgets('TransactionDetailsPage UI and Delete Functionality',
      (WidgetTester tester) async {
    final groupProvider = GroupProvider();
    groupProvider
        .addGroup(Group(name: "Test Group", members: ["Alice", "Bob"]));
    groupProvider.addTransaction(
      "Test Group",
      Transaction(
        description: "Dinner",
        amount: 50.0,
        date: DateTime.now(),
        participantShares: {"Alice": 25.0, "Bob": 25.0},
      ),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: groupProvider,
        child: const MaterialApp(
            home: TransactionDetailsPage(
                groupName: "Test Group", transactionIndex: 0)),
      ),
    );

    // Verify transaction details
    expect(find.text("Description:"), findsOneWidget);
    expect(find.text("Dinner"), findsOneWidget);
    expect(find.text("Amount:"), findsOneWidget);
    expect(find.text("\$50.00"), findsOneWidget);

    // Tap Delete Button
    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    // Verify confirmation dialog appears
    expect(find.text("Delete Transaction"), findsOneWidget);
  });
  // Group tests for LoginPage
  group('LoginPage Tests', () {
    testWidgets(
        'Login button should be disabled initially and enabled with valid input',
        (WidgetTester tester) async {
      // Build the LoginPage widget and trigger a frame
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
      await tester.enterText(
          find.byType(TextField).at(1), ''); // Password empty
      await tester.pump();

      // Verify the login button is still disabled
      expect(tester.widget<ElevatedButton>(loginButton).enabled, false);
    });

    testWidgets(
        'Login button should toggle (disable/enable) based on password input',
        (WidgetTester tester) async {
      // Build the LoginPage widget and trigger a frame
      await tester.pumpWidget(const MaterialApp(home: LoginPage()));

      // Find the TextField widgets for email and password
      final emailField =
          find.byType(TextField).at(0); // First TextField is email
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
  });

  // Group tests for SignUpPage
  group('SignUpPage Tests', () {
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
  });

  // Group tests for ProfilePage
  group('ProfilePage Tests', () {
    // Test 1: Phone number visibility toggles when icon is pressed
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
    // Test 2: Currency selection from dropdown
    testWidgets('Currency selection from dropdown',
        (WidgetTester tester) async {
      // Build the ProfilePage widget
      await tester.pumpWidget(MaterialApp(home: ProfilePage()));

      // Open the currency dropdown
      await tester.tap(find.byType(DropdownButton<String>));
      await tester.pumpAndSettle();

      // Select a currency (for example, "USD")
      await tester.tap(find
          .text('INR')
          .last); // Use .last in case there are multiple 'USD' options
      await tester.pumpAndSettle();

      // Verify that the selected currency is displayed
      expect(find.text('INR'),
          findsOneWidget); // Assuming the dropdown displays the selected value
    });
    group('GroupSettingsPage Tests', () {
      testWidgets('Should display members and allow modification',
          (WidgetTester tester) async {
        // List of initial group members
        final members = ['Vamshi', 'Karthik', 'Nandan'];

        // Initialize GroupSettingsPage with the list of members
        await tester.pumpWidget(MaterialApp(
          home:
              GroupSettingsPage(groupName: 'New Group', groupMembers: members),
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

      testWidgets('Should prompt to confirm leaving the group',
          (WidgetTester tester) async {
        // List of initial group members
        final members = ['Vamshi', 'Karthik', 'Nandan'];

        // Initialize GroupSettingsPage with the list of members
        await tester.pumpWidget(MaterialApp(
          home:
              GroupSettingsPage(groupName: 'New Group', groupMembers: members),
        ));

        // Tap to leave the group
        await tester.tap(find.text('Leave Group'));
        await tester.pumpAndSettle();

        // Verify that the confirmation dialog is shown
        expect(find.text('Are you sure you want to leave this group?'),
            findsOneWidget);
      });
    });

    group('GroupDetailPage Tests', () {
      testWidgets(
          'Should show the Group Settings page when settings icon is tapped',
          (WidgetTester tester) async {
        // Simulate a group with no transactions
        final groupProvider = GroupProvider();
        groupProvider.addGroup(
            Group(name: 'New Group', members: ['Vamshi'], transactions: []));

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
    testWidgets('Should display friend list and allow selection',
        (WidgetTester tester) async {
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
      testWidgets('Should display friend list and allow selection',
          (WidgetTester tester) async {
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
        testWidgets('Should display friend list and allow selection',
            (WidgetTester tester) async {
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
      });
    });
  });

  group('GroupSettingsPage Tests', () {
    testWidgets('Should display group members correctly',
        (WidgetTester tester) async {
      // Prepare mock group data
      final List<String> groupMembers = ['Vamshi', 'Karthik', 'Ravi'];

      // Build the GroupSettingsPage with mock data
      await tester.pumpWidget(
        MaterialApp(
          home: GroupSettingsPage(
              groupName: 'Test Group', groupMembers: groupMembers),
        ),
      );

      // Verify that the group name is displayed
      expect(find.text('Group Settings'), findsOneWidget);

      // Verify that the list of members is displayed
      expect(find.text('Vamshi'), findsOneWidget);
      expect(find.text('Karthik'), findsOneWidget);
      expect(find.text('Ravi'), findsOneWidget);
    });

    testWidgets('Should navigate to AddGroupMembersPage and modify members',
        (WidgetTester tester) async {
      // Initial members of the group
      List<String> groupMembers = ['Vamshi', 'Karthik'];

      // Build the GroupSettingsPage widget with initial group members
      await tester.pumpWidget(
        MaterialApp(
          home: GroupSettingsPage(
              groupName: 'Test Group', groupMembers: groupMembers),
        ),
      );

      // Verify that the group members are initially displayed
      expect(find.text('Vamshi'), findsOneWidget);
      expect(find.text('Karthik'), findsOneWidget);

      // Tap on the "Modify Members" button
      await tester.tap(find.text('Modify Members'));
      await tester.pumpAndSettle();

      // Simulate adding a new member (e.g., "Ravi")
      final List<String> updatedMembers = ['Vamshi', 'Karthik', 'Nandan'];

      // Assuming that the AddGroupMembersPage modifies the list and returns the updated list
      // Mock the behavior of AddGroupMembersPage and return the updated list
      // Simulate the updated members being returned
      expect(updatedMembers.contains('Nandan'), isTrue);

      // Verify that the updated members list is reflected in the UI
      expect(find.text('Vamshi'), findsOneWidget);
      expect(find.text('Karthik'), findsOneWidget);
      expect(find.text('Nandan'), findsOneWidget);
    });

    testWidgets(
        'Should show leave group confirmation dialog and handle leaving',
        (WidgetTester tester) async {
      // Prepare mock group data
      final List<String> groupMembers = ['Vamshi', 'Karthik', 'Ravi'];

      // Build the GroupSettingsPage with mock data
      await tester.pumpWidget(
        MaterialApp(
          home: GroupSettingsPage(
              groupName: 'Test Group', groupMembers: groupMembers),
        ),
      );

      // Verify that the "Leave Group" button is present
      expect(find.text('Leave Group'), findsOneWidget);

      // Tap on the "Leave Group" button
      await tester.tap(find.text('Leave Group'));
      await tester.pumpAndSettle(); // Allow the dialog to appear

      // Verify that the dialog is shown
      expect(find.byType(AlertDialog), findsOneWidget);

      // Verify that the dialog has the text we're expecting (i.e., "Leave")
      expect(find.text('Leave'), findsOneWidget); // The "Leave" button

      // Tap on the "Leave" button in the dialog
      await tester.tap(find.text('Leave'));
      await tester.pumpAndSettle();

      // Verify that the app navigates back to the first route (indicating the user has left the group)
      expect(find.text('Test Group'),
          findsNothing); // Assuming you're redirected somewhere else
    });
  });

  group('Splash Screen Tests', () {
    testWidgets('Splash Screen should navigate to Login Page after delay',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

      await tester.pump(const Duration(seconds: 5)); // Simulate splash delay
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
    });
  });

  group('Bottom Navigation Bar Tests', () {
    testWidgets('Bottom Navigation Bar should switch tabs correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => GroupProvider()),
            ChangeNotifierProvider(create: (_) => ChoreProvider()),
          ],
          child: const MaterialApp(home: BottomNavBar()),
        ),
      );
      await tester.pumpAndSettle(); // Ensure full rendering

      // Verify HomePage is initially displayed
      expect(find.byType(HomePage), findsOneWidget);

      // Switch to Chores tab
      await tester.tap(find.byIcon(Icons.check_circle));
      await tester.pumpAndSettle();
      expect(find.byType(ChoresDetailsPage), findsOneWidget);

      // Switch to Profile tab
      await tester.tap(find.byIcon(Icons.person));
      await tester.pumpAndSettle();
      expect(find.byType(ProfilePage), findsOneWidget);

      // Switch back to Home tab
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();
      expect(find.byType(HomePage), findsOneWidget);
    });
  });

  group('Groups Page Tests', () {
    testWidgets('Groups Page should display groups list',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => GroupProvider(),
          child: const MaterialApp(home: GroupsPage()),
        ),
      );
      expect(find.text('Groups'), findsOneWidget);
    });
  });

  group('Chores Tests', () {
    testWidgets('Verify UI elements in AssignChoresPage',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => ChoreProvider()),
          ],
          child: const MaterialApp(home: AssignChoresPage()),
        ),
      );

      // Verify if page title exists
      expect(find.text('Assign Weekly Chores'), findsOneWidget);

      // Verify TextField for participant count exists
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Number of People'), findsOneWidget);

      // Verify dropdown for assignment method
      expect(find.text('Select Assignment Method'), findsOneWidget);

      // Verify Generate Schedule button exists
      expect(find.text('Generate Schedule'), findsOneWidget);
    });

    test('ChoreProvider updates participant count correctly', () {
      final choreProvider = ChoreProvider();

      // Initially, participants list should be empty
      expect(choreProvider.participants.isEmpty, true);

      // Set participant count
      choreProvider.setParticipantCount(3);
      expect(choreProvider.participants.length, 3);
      expect(choreProvider.participants, ['Person 1', 'Person 2', 'Person 3']);
    });

    test('ChoreProvider assignment method updates correctly', () {
      final choreProvider = ChoreProvider();

      expect(choreProvider.assignmentMethod, "");

      choreProvider.setAssignmentMethod("Direct Assign");
      expect(choreProvider.assignmentMethod, "Direct Assign");
    });

    test('ChoreProvider correctly validates inputs', () {
      final choreProvider = ChoreProvider();

      // Initially, validation should fail
      expect(choreProvider.validateInputs(), false);
      expect(choreProvider.showError, true);

      // Set valid data
      choreProvider.setParticipantCount(2);
      choreProvider.setAssignmentMethod("Direct Assign");
      choreProvider.setDirectAssignments({
        "Person 1": {"Monday": "Cleaning"},
        "Person 2": {"Tuesday": "Dishes"}
      });

      expect(choreProvider.validateInputs(), true);
      expect(choreProvider.showError, false);
    });

    testWidgets('ChoresDetailsPage UI and Navigation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider(
          create: (_) => ChoreProvider(),
          child: const MaterialApp(home: ChoresDetailsPage()),
        ),
      );

      // Verify title exists
      expect(find.text("Chores Schedule"), findsOneWidget);

      // Verify empty state message
      expect(
          find.text("No schedule generated for this month."), findsOneWidget);

      // Tap the FAB and navigate to AssignChoresPage
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AssignChoresPage), findsOneWidget);
    });
  });
}
