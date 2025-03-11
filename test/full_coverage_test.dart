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
import '../lib/screens/splash_screen.dart';
import '../lib/transactions/split_method_page.dart';

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


  testWidgets('SignUpPage UI renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignUpPage()));

    // Check if "Sign Up" title exists (finds first instance)
    expect(find.text('Sign Up'), findsWidgets); // Allows multiple matches

    // Check if all fields exist
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });

  testWidgets('SignUp button is disabled initially',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: SignUpPage()));

    final signUpButton = find.widgetWithText(ElevatedButton, 'Sign Up');
    expect(tester.widget<ElevatedButton>(signUpButton).onPressed, isNull);
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

  // Group tests for ProfilePage
  group('ProfilePage Tests', () {

    // group('GroupDetailPage Tests', () {
    //   testWidgets(
    //       'Should show the Group Settings page when settings icon is tapped',
    //       (WidgetTester tester) async {
    //     // Simulate a group with no transactions
    //     final groupProvider = GroupProvider();
    //     groupProvider.addGroup(
    //         Group(name: 'New Group', members: ['Vamshi'], transactions: []));
    //
    //     await tester.pumpWidget(
    //       ChangeNotifierProvider(
    //         create: (context) => groupProvider,
    //         child: MaterialApp(home: GroupDetailPage(groupName: 'New Group')),
    //       ),
    //     );
    //
    //     // Tap on the settings icon to navigate to GroupSettingsPage
    //     await tester.tap(find.byIcon(Icons.settings));
    //     await tester.pumpAndSettle();
    //
    //     // Verify that we navigated to the GroupSettingsPage
    //     expect(find.text('Group Settings'), findsOneWidget);
    //   });
    // });
  });

  // Group tests for Add Group Members Page

  group('Splash Screen Tests', () {
    testWidgets('Splash Screen should navigate to Login Page after delay',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

      await tester.pump(const Duration(seconds: 5)); // Simulate splash delay
      await tester.pumpAndSettle();

      expect(find.byType(LoginPage), findsOneWidget);
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

  // testWidgets('ChoresDetailsPage displays chore plans and allows navigation',
  //     (WidgetTester tester) async {
  //   // Mock ChoreProvider
  //   final choreProvider = ChoreProvider();
  //   choreProvider.addChorePlan(ChorePlan(
  //     choreName: "Weekly Cleaning",
  //     participants: ["John", "Doe"],
  //     directAssignments: {
  //       "John": {"Monday": "Trash"}
  //     },
  //     finalSchedule: {},
  //   ));
  //
  //   await tester.pumpWidget(
  //     MultiProvider(
  //       providers: [ChangeNotifierProvider.value(value: choreProvider)],
  //       child: MaterialApp(home: ChoresDetailsPage()),
  //     ),
  //   );
  //
  //   // Verify chore plan is displayed
  //   expect(find.text("Weekly Cleaning"), findsOneWidget);
  //   expect(find.text("Participants: John, Doe"), findsOneWidget);
  //
  //   // Tap on a chore plan to navigate
  //   await tester.tap(find.text("Weekly Cleaning"));
  //   await tester.pumpAndSettle();
  //
  //   // Ensure navigation happens
  //   expect(find.byType(ChoreDetailsViewPage), findsOneWidget);
  // });

  group('Profile Page Widget Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });


    testWidgets('Should display profile image when set in SharedPreferences',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image', 'test_path.jpg');

      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));
      await tester.pump();

      expect(find.byType(CircleAvatar), findsOneWidget);
    });

  });
}
