import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:movies/LoginPage.dart';
import 'package:movies/moviesPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 
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


class AuthCheck extends StatelessWidget {
  final Function(bool) toggleTheme;
  final bool isDarkMode;

  AuthCheck({required this.toggleTheme, required this.isDarkMode});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), 
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator())); 
        }
        if (snapshot.hasData) {
          return MoviesPage();
        }
        return LoginPage(toggleTheme: toggleTheme, isDarkMode: isDarkMode); 
      },
    );
  }
}
