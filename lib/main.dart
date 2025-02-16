import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:movies/LoginPage.dart';
import 'package:movies/moviesPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Ensure Firebase is initialized
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  void toggleTheme(bool value) {
    setState(() {
      isDarkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: AuthCheck(toggleTheme: toggleTheme, isDarkMode: isDarkMode),
    );
  }
}

// ✅ This widget checks if the user is logged in
class AuthCheck extends StatelessWidget {
  final Function(bool) toggleTheme;
  final bool isDarkMode;

  AuthCheck({required this.toggleTheme, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // ✅ Listen for auth state changes
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator())); // Show loading screen
        }
        if (snapshot.hasData) {
          return MoviesPage(); // ✅ User is logged in, go to Movies Page
        }
        return LoginPage(toggleTheme: toggleTheme, isDarkMode: isDarkMode); // ✅ Show Login Page if not logged in
      },
    );
  }
}
