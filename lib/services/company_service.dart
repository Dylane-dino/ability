// lib/services/company_service.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CompanyService {
  static const String _baseUrl = 'http://10.244.16.141:3000/api/companies';

  // Fetch admin user ID for a company
  Future<Map<String, dynamic>?> getCompanyAdmin(int companyId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/$companyId/admin'),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching company admin: $e');
      return null;
    }
  }
}
