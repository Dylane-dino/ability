// lib/services/application_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/application.dart';

class ApplicationService {
  static const String _baseUrl = 'http://192.168.88.176:3000/api/applications';

  // --- SUBMIT JOB APPLICATION ---
  Future<bool> submitApplication({
    required int jobId,
    required int seekerId,
    String? coverLetter,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'job_id': jobId,
          'seeker_id': seekerId,
          'cover_letter': coverLetter,
        }),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Application Error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Network Error: $e');
      return false;
    }
  }

  // --- GET APPLICATIONS FOR A SPECIFIC JOB (Employer view) ---
  Future<List<Application>> getJobApplications(int jobId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/job/$jobId'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Application.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load applications');
      }
    } catch (e) {
      print('Error fetching job applications: $e');
      return [];
    }
  }

  // --- GET APPLICATIONS MADE BY A SEEKER (Seeker's history) ---
  Future<List<Application>> getSeekerApplications(int seekerId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/seeker/$seekerId'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Application.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load applications');
      }
    } catch (e) {
      print('Error fetching seeker applications: $e');
      return [];
    }
  }

  // --- UPDATE APPLICATION STATUS (Accept/Reject/Offer Interview) ---
  Future<bool> updateApplicationStatus({
    required int applicationId,
    required String status,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$applicationId/status'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'status': status}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating status: $e');
      return false;
    }
  }

  // --- GET AUTH HEADERS ---
  Future<Map<String, String>> _getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}
