import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CommunityService {
  // 🛠️ Note: Remember to update this IP to your live Hostinger VPS IP address once you deploy!
  static const String _baseUrl = 'http://10.244.16.141:3000';

  // ==========================================
  // GET LEARNING RESOURCES
  // ==========================================
  static Future<List<Map<String, dynamic>>> fetchLearningResources() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/community/learning'),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        print('Error fetching learning resources: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Network error fetching learning resources: $e');
      return [];
    }
  }

  // ==========================================
  // GET MENTORS
  // ==========================================
  static Future<List<Map<String, dynamic>>> fetchMentors() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/community/mentors'),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        print('Error fetching mentors: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Network error fetching mentors: $e');
      return [];
    }
  }

  // ==========================================
  // GET FORUM POSTS
  // ==========================================
  static Future<List<Map<String, dynamic>>> fetchForumPosts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/community/forum'),
      );

      if (response.statusCode == 200) {
        return List<Map<String, dynamic>>.from(jsonDecode(response.body));
      } else {
        print('Error fetching forum posts: ${response.body}');
        return [];
      }
    } catch (e) {
      print('Network error fetching forum posts: $e');
      return [];
    }
  }

  // ==========================================
  // REQUEST MENTORSHIP
  // ==========================================
  static Future<Map<String, dynamic>> requestMentorship(
    int mentorId, {
    String message = '',
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int? seekerId = prefs.getInt('userId');

      if (seekerId == null) {
        return {'success': false, 'message': 'Please login first'};
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/api/community/mentorship-request'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'seeker_id': seekerId,
          'mentor_id': mentorId,
          'message': message,
        }),
      );

      final responseData = jsonDecode(response.body);
      if (response.statusCode == 201) {
        return {'success': true, 'message': responseData['message']};
      } else {
        return {
          'success': false,
          'message': responseData['message'] ?? 'Failed to send request',
        };
      }
    } catch (e) {
      print('Error requesting mentorship: $e');
      return {'success': false, 'message': 'Network error'};
    }
  }
}
