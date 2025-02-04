import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import provider package
import 'package:spendmate/chores/chores_page.dart';
import 'package:spendmate/providers/transaction_provider.dart';
import 'package:spendmate/groups/groups_page.dart';
import 'package:spendmate/screens/home_page.dart';
import 'package:spendmate/user_section/login_page.dart';
import 'package:spendmate/user_section/profile_page.dart';
import 'package:spendmate/user_section/signup_page.dart';

void main() {
  runApp(const SpendMateApp());
}

class SpendMateApp extends StatelessWidget {
  const SpendMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GroupProvider(), // Provide the GroupProvider to the app
      child: MaterialApp(
        title: 'SpendMate',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/login',
        routes: {
          '/': (context) => const BottomNavBar(),  // The main page with bottom nav
          '/login': (context) => const LoginPage(), // Login page
          '/signup': (context) => const SignUpPage(), // SignUp page
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  _BottomNavBarState createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const GroupsPage(),
    const ChoresPage(),   // Chores Page
    const ProfilePage(), // Profile Page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Update to reflect pages with Profile and Chores
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task), // Chores Icon
            label: 'Chores',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,
        onTap: _onItemTapped,
      ),
    );
  }
}
