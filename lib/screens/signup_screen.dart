// lib/screens/signup_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _companyController = TextEditingController();

  String _selectedRole = 'seeker'; // Default to seeker
  bool _isLoading = false;

  Future<void> _handleSignup() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // OOP Concept: Call the service layer, keep UI clean
      bool success = await AuthService().register(
        _emailController.text,
        _passwordController.text,
        _selectedRole,
        companyName: _selectedRole == 'employer'
            ? _companyController.text
            : null,
      );

      setState(() => _isLoading = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Account created successfully! Please log in."),
          ),
        );
        Navigator.pop(context); // Send them back to Login screen
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to create account.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Create an Account")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email Address"),
                validator: (val) => val!.isEmpty ? 'Enter an email' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: "Password"),
                obscureText: true,
                validator: (val) =>
                    val!.length < 6 ? 'Password must be 6+ chars' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: "I am a..."),
                items: const [
                  DropdownMenuItem(value: 'seeker', child: Text("Job Seeker")),
                  DropdownMenuItem(value: 'employer', child: Text("Employer")),
                ],
                onChanged: (val) {
                  setState(() {
                    _selectedRole = val!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // 🚀 DYNAMIC UI: Only show this if they are an employer!
              if (_selectedRole == 'employer')
                TextFormField(
                  controller: _companyController,
                  decoration: const InputDecoration(
                    labelText: "Your Company Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (val) => val!.isEmpty
                      ? 'Company name is required for employers'
                      : null,
                ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignup,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Sign Up", style: TextStyle(fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
