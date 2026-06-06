import 'dart:convert'; // Added to ensure json encoding/decoding works if needed
import 'package:flutter/material.dart';
import '../app_components.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  void _handleLogin() async {
    // 1. Validation Check
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter both email and password"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    // 2. Network API Query to your Node.js server
    final responseData = await ApiService.loginUser(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    // 3. Process the server response
    if (responseData != null && responseData['user'] != null) {
      // SUCCESS! Fetch user meta-data
      final prefs = await SharedPreferences.getInstance();
      final userMap = responseData['user'];

      // Save general credentials locally for active session tracking
      await prefs.setString('userName', userMap['name'] ?? 'User');
      await prefs.setString('userEmail', userMap['email'] ?? '');

      String role = userMap['role'] ?? 'seeker';
      await prefs.setString('role', role);

      // 🛠️ CRITICAL ADDITION: Save user IDs to handle localized dashboard queries
      if (userMap['id'] != null) {
        await prefs.setInt('userId', userMap['id'] as int);
      }

      // If your backend nests employer profiles specifically or returns an explicit employerId:
      if (userMap['employerId'] != null) {
        await prefs.setInt('employerId', userMap['employerId'] as int);
      } else if (role == 'employer' && userMap['id'] != null) {
        // Fallback: Use user primary key if your table structures share a profile mapping identity
        await prefs.setInt('employerId', userMap['id'] as int);
      }

      // Route to the corresponding dashboard registered in main.dart
      if (role == 'employer') {
        Navigator.pushReplacementNamed(context, '/employer');
      } else {
        Navigator.pushReplacementNamed(context, '/seeker');
      }
    } else {
      // FAIL! Display a single error notification
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Invalid email or password."),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 24.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                const Icon(
                  Icons.accessibility_new,
                  size: 80,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 20),
                const Text(
                  "Welcome Back!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 30),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 30),

                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : CustomButton(label: "Login", onTap: _handleLogin),

                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/signup'),
                    child: const Text(
                      "Don't have an account? Sign Up Here",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
