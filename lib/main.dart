import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:spendmate/providers/chores_provider.dart';
import 'package:spendmate/providers/group_provider.dart';
import 'package:spendmate/providers/transaction_provider.dart';
import 'package:spendmate/firebase_options.dart'; // Generated file
import 'package:spendmate/screens/splash_screen.dart';
import 'package:spendmate/user_section/login_page.dart';
import 'package:spendmate/user_section/signup_page.dart';
import 'package:spendmate/widgets/bottom_nav_bar.dart';

import 'firebase_authentication_service.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SpendMateApp());
}

class SpendMateApp extends StatelessWidget {
  const SpendMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => GroupProvider()),
        ChangeNotifierProvider(create: (context) => TransactionProvider()),
        ChangeNotifierProvider(create: (context) => ChoreProvider()),
        Provider<AuthService>(create: (context) => AuthService()), // Provide AuthService
      ],
      child: StreamBuilder<User?>(
        // Listen to auth state changes
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          return MaterialApp(
            title: 'SpendMate',
            theme: ThemeData(
              primarySwatch: Colors.teal,
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            initialRoute: '/splash',
            routes: {
              '/': (context) => snapshot.hasData
                  ? const BottomNavBar()
                  : const LoginPage(),
              '/login': (context) => const LoginPage(),
              '/signup': (context) => const SignUpPage(),
              '/splash': (context) => const SplashScreen(),
            },
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}