import 'package:flutter/material.dart';
import 'package:spendmate/chores/chores_page.dart';
import 'package:spendmate/groups/groups_page.dart';
import 'package:spendmate/screens/home_page.dart';
import 'package:spendmate/user_section/profile_page.dart';

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
    const ProfilePage(),  // Add ProfilePage to navigation
    const ChoresPage(),    // Add ChoresPage to navigation
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),  // Home Icon
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.group),  // Groups Icon
            label: 'Groups',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.task),  // Chores Icon
            label: 'Chores',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.teal,  // Color when selected
        unselectedItemColor: Colors.grey,  // Color when not selected (grey)
        onTap: _onItemTapped,
      ),
    );
  }
}
