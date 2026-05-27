// lib/services/message_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class MessageService {
  static const String _baseUrl = 'http://192.168.88.176:3000/api/messages';

  // --- SEND A MESSAGE ---
  Future<bool> sendMessage({
    required int senderId,
    required int receiverId,
    required String content,
    int? jobId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: await _getAuthHeaders(),
        body: jsonEncode({
          'sender_id': senderId,
          'receiver_id': receiverId,
          'job_id': jobId,
          'content': content,
        }),
      );

      return response.statusCode == 201;
    } catch (e) {
      print('Error sending message: $e');
      return false;
    }
  }

  // --- GET CONVERSATION BETWEEN TWO USERS (optionally for a specific job) ---
  Future<List<Map<String, dynamic>>> getConversation({
    required int userId,
    required int otherUserId,
    int? jobId,
  }) async {
    try {
      final queryParams = {
        'userId': userId.toString(),
        'otherUserId': otherUserId.toString(),
        if (jobId != null) 'jobId': jobId.toString(),
      };

      final uri = Uri.parse('$_baseUrl/conversation').replace(queryParameters: queryParams);

      final response = await http.get(uri, headers: await _getAuthHeaders());

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load conversation');
      }
    } catch (e) {
      print('Error fetching conversation: $e');
      return [];
    }
  }

  // --- GET ALL CONVERSATIONS FOR A USER (list of chat partners) ---
  Future<List<Map<String, dynamic>>> getUserConversations(int userId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/conversations?userId=$userId'),
        headers: await _getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception('Failed to load conversations');
      }
    } catch (e) {
      print('Error fetching conversations: $e');
      return [];
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
