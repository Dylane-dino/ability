// lib/services/api_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://192.168.1.138:3000/api/auth';

  // --- REGISTER REQUEST ---
  static Future<bool> registerUser(
    String email,
    String password,
    String role, {
    String? companyName,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          'role': role,
          'companyName': companyName,
        }),
      );

      if (response.statusCode == 201) {
        return true; // Success!
      } else {
        print('Backend Error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Network Error: $e');
      return false;
    }
  }

  // --- LOGIN REQUEST ---
  // Now returns a Map with data so we can check the user's role
  static Future<Map<String, dynamic>?> loginUser(
    String email,
    String password,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        // Decode the JSON response from the backend
        final data = jsonDecode(response.body);
        return data; // Returns { "message": "...", "token": "...", "user": { "role": "..." } }
      } else {
        print('Login Failed: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Network Error: $e');
      return null;
    }
  }
}
