import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';
import 'screens/signup_page.dart';

void main() {
  runApp(const SpendMateApp());
}

class SpendMateApp extends StatelessWidget {
  const SpendMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SpendMate',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // Start the app on the login page
      initialRoute: '/login', // Change this to /login to start at LoginPage
      routes: {
        '/': (context) => const HomePage(), // HomePage now only after login/signup
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}
