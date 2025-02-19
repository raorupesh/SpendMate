import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/providers/transaction_provider.dart';
import 'package:spendmate/user_section/login_page.dart';
import 'package:spendmate/user_section/signup_page.dart';
import 'package:spendmate/widgets/bottom_nav_bar.dart';

void main() {
  runApp(const SpendMateApp());
}

class SpendMateApp extends StatelessWidget {
  const SpendMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GroupProvider(),
      child: MaterialApp(
        title: 'SpendMate',
        theme: ThemeData(
          primarySwatch: Colors.teal,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        initialRoute: '/login',
        routes: {
          '/': (context) => const BottomNavBar(),
          '/login': (context) => const LoginPage(),
          '/signup': (context) => const SignUpPage(),
        },
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
