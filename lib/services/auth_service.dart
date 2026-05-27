import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';

class AuthService {
  // --- REGISTER ---
  Future<bool> register(
    String email,
    String password,
    String role, {
    String? companyName,
  }) async {
    try {
      final response = await ApiService.registerUser(
        email,
        password,
        role,
        companyName: companyName,
      );

      return response;
    } catch (e) {
      print("Registration error: $e");
      return false;
    }
  }

  // --- LOGIN ---
  Future<bool> login(String email, String password) async {
    try {
      final data = await ApiService.loginUser(email, password);

      if (data != null) {
        // Save the token and user data directly to the device's storage
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setInt('userId', data['user']['id']);
        await prefs.setString('role', data['user']['role']);

        // 🚀 SAVE THE COMPANY ID IF THIS USER IS AN EMPLOYER
        if (data['user']['companyId'] != null) {
          await prefs.setInt('companyId', data['user']['companyId']);
        }

        return true;
      }

      print("Login failed: No data returned");
      return false;
    } catch (e) {
      print("Login error: $e");
      return false;
    }
  }
}
