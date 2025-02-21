import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/providers/transaction_provider.dart';
import 'package:spendmate/providers/chores_provider.dart'; // Import ChoreProvider
import 'package:spendmate/user_section/login_page.dart';
import 'package:spendmate/user_section/signup_page.dart';
import 'package:spendmate/screens/splash_screen.dart';
import 'package:spendmate/widgets/bottom_nav_bar.dart';

void main() {
  runApp(const SpendMateApp());
}

class SpendMateApp extends StatelessWidget {
  const SpendMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GroupProvider()),
        ChangeNotifierProvider(create: (context) => ChoreProvider()), // Added ChoreProvider
      ],
      child: MaterialApp(
        title: 'SpendMate',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/splash',
        routes: {
          '/': (context) => const BottomNavBar(),
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignUpPage(),
          '/splash': (context) => const SplashScreen(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
