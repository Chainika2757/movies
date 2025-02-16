import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:movies/MoviesPage.dart'; // Ensure MoviesPage is imported
import 'package:movies/SignUpPage.dart';

class LoginPage extends StatefulWidget {
  final Function(bool) toggleTheme;
  final bool isDarkMode;

  LoginPage({required this.toggleTheme, required this.isDarkMode});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool isLoading = false;
  bool obscurePassword = true;
  String? emailError;
  String? passwordError;

  Future<void> login() async {
    setState(() {
      emailError = _validateEmail(emailController.text);
      passwordError = _validatePassword(passwordController.text);
    });

    if (emailError != null || passwordError != null) return;

    setState(() {
      isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      if (userCredential.user != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Login Successful!"), backgroundColor: Colors.green),
        );

        // ✅ Navigate to MoviesPage after login
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MoviesPage()),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
      );
    }
  }

  String? _validateEmail(String email) {
    if (email.isEmpty) return "Email is required";

    /// ✅ Fixed Regex
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      return "Invalid email format";
    }
    return null;
  }

  String? _validatePassword(String password) {
    if (password.isEmpty) return "Password is required";
    if (password.length < 7 || !RegExp(r'\d').hasMatch(password)) {
      return "Password must be at least 7 characters long and contain a number";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Movies"),
        centerTitle: true,
        actions: [
          Switch(
            value: widget.isDarkMode,
            onChanged: widget.toggleTheme,
          ),
        ],
      ),
      backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: "Email",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email, color: Colors.redAccent),
                  errorText: emailError,
                ),
              ),
              SizedBox(height: 15),

              TextField(
                controller: passwordController,
                obscureText: obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock, color: Colors.redAccent),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      setState(() {
                        obscurePassword = !obscurePassword;
                      });
                    },
                  ),
                  errorText: passwordError,
                ),
              ),
              SizedBox(height: 25),

              GestureDetector(
                onTap: isLoading ? null : login,
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: isLoading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            "Login",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ),
              SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Don't have an account?"),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => SignUpPage()),
                      );
                    },
                    child: Text("Sign Up", style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
