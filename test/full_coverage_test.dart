import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendmate/groups/add_group_members_page.dart';
import 'package:spendmate/user_section/login_page.dart';
import 'package:spendmate/user_section/profile_page.dart';
import 'package:spendmate/user_section/signup_page.dart';
import '../lib/groups/group_settings_page.dart';
import '../lib/groups/groups_page.dart';
import '../lib/groups/select_participants_page.dart';
import '../lib/providers/group_provider.dart';

import '../lib/transactions/split_method_page.dart';
import '../lib/validations/credential_validation_page.dart';

class MockGroupProvider extends Mock implements GroupProvider {}

void main() {
  late MockGroupProvider mockGroupProvider;

  setUp(() {
    mockGroupProvider = MockGroupProvider();
  });

  Widget createTestWidget({required Widget child}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<GroupProvider>.value(value: mockGroupProvider),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }
group('GroupMembers Page Test', (){
  testWidgets('Displays group name and members', (WidgetTester tester) async {
  const testGroupName = 'Test Group';
  final testGroupMembers = ['Alice', 'Bob', 'Charlie'];

  await tester.pumpWidget(
    createTestWidget(
      child: GroupSettingsPage(
        groupId: 'group123',
        groupName: testGroupName,
        groupMembers: testGroupMembers,
        onLeaveGroup: (_) {},
      ),
    ),
  );

  // Verify group name
  expect(find.text(testGroupName), findsOneWidget);

  // Verify members
  for (var member in testGroupMembers) {
    expect(find.text(member), findsOneWidget);
  }
});

testWidgets('Navigates to AddGroupMembersPage when Modify Members is clicked',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: GroupSettingsPage(
            groupId: 'group123',
            groupName: 'Test Group',
            groupMembers: ['Alice', 'Bob'],
            onLeaveGroup: (_) {},
          ),
        ),
      );

      // Tap Modify Members button
      await tester.tap(find.text('Modify Members'));
      await tester.pumpAndSettle();

      // Verify navigation to AddGroupMembersPage
      expect(find.byType(AddGroupMembersPage), findsOneWidget);
    });

testWidgets('Shows confirmation dialog when Leave Group is clicked',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        createTestWidget(
          child: GroupSettingsPage(
            groupId: 'group123',
            groupName: 'Test Group',
            groupMembers: ['Alice', 'Bob'],
            onLeaveGroup: (_) {},
          ),
        ),
      );

      // Tap Leave Group button
      await tester.tap(find.text('Leave Group'));
      await tester.pumpAndSettle();

      // Verify dialog appears
      expect(find.text('Leave Group'), findsNWidgets(2)); // Button & Dialog Title
      expect(find.text('Are you sure you want to leave this group?'), findsOneWidget);

      // Tap cancel button
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Dialog should be dismissed
      expect(find.text('Are you sure you want to leave this group?'), findsNothing);
    });});


  group('SplitMethodPage tests', () {
    testWidgets('Default split method is Equal', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplitMethodPage(
            splitMethod: 'Equal',
            onSave: (_) {},
          ),
        ),
      );

      // Check that 'Equal Split' is selected by default
      expect(find.text('Equal Split'), findsOneWidget);

      // The radio for 'Equal' should be selected
      final radio = find.byWidgetPredicate((widget) {
        if (widget is Radio<String>) {
          return widget.value == 'Equal' && widget.groupValue == 'Equal';
        }
        return false;
      });
      expect(radio, findsOneWidget);
    });

    testWidgets('Selecting Custom shows the custom TextField', (
        WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplitMethodPage(
            splitMethod: 'Equal',
            onSave: (_) {},
          ),
        ),
      );

      // Tap on the 'Custom' tile
      await tester.tap(find.text('Custom Split'));
      await tester.pumpAndSettle();
    });

    testWidgets('Selecting Percentage shows the percentage TextField', (
        WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplitMethodPage(
            splitMethod: 'Equal',
            onSave: (_) {},
          ),
        ),
      );

      // Tap on 'Percentage Split'
      await tester.tap(find.text('Percentage Split'));
      await tester.pumpAndSettle();
    });
    testWidgets('Default split method is Equal', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SplitMethodPage(
            splitMethod: 'Equal',
            onSave: (_) {},
          ),
        ),
      );

      // Verify default selection
      expect(find.text('Equal Split'), findsOneWidget);
    });
  });

  group('SelectParticipantsPage Tests', () {
    testWidgets('Displays participants and allows selection',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SelectParticipantsPage(
            members: ['Alice', 'Bob', 'Charlie'],
            selectedParticipants: [],
          ),
        ),
      );

      // Check if all participant names are displayed
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Charlie'), findsOneWidget);

      // Tap to select 'Alice'
      await tester.tap(find.text('Alice'));
      await tester.pump();

      // Verify selection
      expect(find.byType(CheckboxListTile), findsNWidgets(3));
    });

    testWidgets('Selecting participants and navigating back returns data',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SelectParticipantsPage(
            members: ['Alice', 'Bob'],
            selectedParticipants: ['Bob'],
          ),
        ),
      );

      // Ensure Bob is pre-selected
      expect(find.text('Bob'), findsOneWidget);

      // Select Alice
      await tester.tap(find.text('Alice'));
      await tester.pump();

      // Press the back button
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Ensure navigation happens and selection is saved
      expect(find.text('Select Participants'), findsNothing);
    });
  });

  group('SharedPreferences Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    test('Should save and retrieve profile image path', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', 'test_path.jpg');

      final storedImagePath = prefs.getString('profile_image');
      expect(storedImagePath, 'test_path.jpg');
    });

    test('Should save and retrieve selected currency', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_currency', 'INR');

      final currency = prefs.getString('selected_currency');
      expect(currency, 'INR');
    });

    test('Should save and retrieve selected timezone', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_timezone', 'IST');

      final timezone = prefs.getString('selected_timezone');
      expect(timezone, 'IST');
    });

    test('Should clear all preferences', () async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('selected_currency', 'USD');
      await prefs.clear();

      final currency = prefs.getString('selected_currency');
      expect(currency, null);
    });
  });

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

  group('validateFields Tests', () {
    late TextEditingController emailController;
    late TextEditingController passwordController;
    late bool isButtonEnabled;
    late String emailError;
    late String passwordError;

    void updateButtonState(Function callback) {
      isButtonEnabled = callback();
    }

    void updateErrorMessages(String email, String password) {
      emailError = email;
      passwordError = password;
    }

    setUp(() {
      emailController = TextEditingController();
      passwordController = TextEditingController();
      isButtonEnabled = false;
      emailError = '';
      passwordError = '';
    });

    test('Should show error when email is empty', () {
      validateFields(
        emailController,
        passwordController,
        updateButtonState: updateButtonState,
        updateErrorMessages: updateErrorMessages,
        isSignUp: false,
      );

      expect(emailError, 'Email cannot be empty');
      expect(passwordError, 'Password cannot be empty');
      expect(isButtonEnabled, false);
    });

    test('Should show error for invalid email format', () {
      emailController.text = 'invalidemail';
      passwordController.text = 'validPass123';

      validateFields(
        emailController,
        passwordController,
        updateButtonState: updateButtonState,
        updateErrorMessages: updateErrorMessages,
        isSignUp: false,
      );

      expect(emailError, 'Invalid email address');
      expect(passwordError, '');
      expect(isButtonEnabled, false);
    });

    test('Should show error for short password', () {
      emailController.text = 'test@example.com';
      passwordController.text = '123';

      validateFields(
        emailController,
        passwordController,
        updateButtonState: updateButtonState,
        updateErrorMessages: updateErrorMessages,
        isSignUp: false,
      );

      expect(emailError, '');
      expect(passwordError, 'Password must be at least 6 characters');
      expect(isButtonEnabled, false);
    });

    test('Should pass validation for valid email and password', () {
      emailController.text = 'test@example.com';
      passwordController.text = 'validPass123';

      validateFields(
        emailController,
        passwordController,
        updateButtonState: updateButtonState,
        updateErrorMessages: updateErrorMessages,
        isSignUp: false,
      );

      expect(emailError, '');
      expect(passwordError, '');
      expect(isButtonEnabled, true);
    });
  });

}
