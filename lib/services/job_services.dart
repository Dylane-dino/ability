import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job_listing.dart';

class JobService {
  static const String _baseUrl = 'http://192.168.88.176:3000';

  // ==========================================
  // FETCH ALL JOBS (For Seeker Dashboard)
  // ==========================================
  Future<List<JobListing>> fetchJobs() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/jobs'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => JobListing.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load jobs from backend service.");
      }
    } catch (e) {
      print("Error fetching jobs: $e");
      return [];
    }
  }

  // ==========================================
  // POST A NEW JOB (For Employer Dashboard)
  // ==========================================
  Future<bool> postJob(JobListing job) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? userEmail = prefs.getString('userEmail');
      final int? employerId = prefs.getInt('employerId');
      final int? companyId = job.companyId;

      if (companyId == null || companyId == 0) {
        print("❌ [FLUTTER DEBUG] companyId is missing from job object");
        return false;
      }

      print("🚀 [FLUTTER DEBUG] Employer ID: '$employerId', Company ID: '$companyId'");

      final response = await http.post(
        Uri.parse('$_baseUrl/api/jobs'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'company_id': companyId,
          'employer_id': employerId,
          'employer_email': userEmail ?? '',
          'title': job.title,
          'description': job.description,
          'job_type': job.jobType,
          'is_remote': job.isRemote ? 1 : 0,
          'accommodation_offerings': job.accommodations ?? [],
        }),
      );

      print("📡 [SERVER RESPONSE STATUS CODE]: ${response.statusCode}");
      print("📡 [SERVER RESPONSE BODY DATA]: ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ [FLUTTER DEBUG] Job registration transaction completed successfully!");
        return true;
      } else {
        print("❌ [FLUTTER DEBUG] Server rejected transaction with code: ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("💥 [FLUTTER DEBUG] Network infrastructure layer crash error: $e");
      return false;
    }
  }

  // ==========================================
  // 🚀 FETCH EMPLOYER DASHBOARD METRICS & JOBS BY ID
  // ==========================================
  Future<Map<String, dynamic>> fetchEmployerDashboardData(
    int employerId,
  ) async {
    try {
      print("📡 [SERVICE] Fetching employer dashboard for ID: $employerId");

      // 🛠️ Points explicitly to your dynamic clean backend REST API route
      final response = await http.get(
        Uri.parse('$_baseUrl/api/employers/dashboard/$employerId'),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final List<dynamic> jobsJson = responseData['jobs'] ?? [];
        final List<JobListing> parsedJobs = jobsJson
            .map((json) => JobListing.fromJson(json))
            .toList();

        print(
          "✅ [SERVICE] Dashboard layout parsed. Total jobs found: ${parsedJobs.length}",
        );

        return {'stats': responseData['stats'], 'jobs': parsedJobs};
      } else {
        print(
          "❌ [SERVICE] Server returned dashboard error code: ${response.statusCode}",
        );
        return {
          'stats': {'totalPosts': 0, 'totalApps': 0, 'interviews': 0},
          'jobs': <JobListing>[],
        };
      }
    } catch (e) {
      print(
        "💥 [SERVICE CRASH] Failed to fetch employer dashboard payload: $e",
      );
      return {
        'stats': {'totalPosts': 0, 'totalApps': 0, 'interviews': 0},
        'jobs': <JobListing>[],
      };
    }
  }

  // ==========================================
  // SUBMIT JOB APPLICATION (For Seeker Detail Screen)
  // ==========================================
  Future<Map<String, dynamic>> applyToJob(int jobId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // 1. Pull the cached active seeker user ID from your session state
      final int? seekerId = prefs.getInt('userId');

      if (seekerId == null) {
        print(
          "⚠️ [SERVICE] Application failed: No active userId found in cache.",
        );
        return {
          'success': false,
          'message': 'Please re-login to submit applications.',
        };
      }

      print(
        "📡 [SERVICE] Dispatching job application to server. Job ID: $jobId, Seeker ID: $seekerId",
      );

      final response = await http.post(
        Uri.parse('$_baseUrl/api/applications'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'job_id': jobId, 'seeker_id': seekerId}),
      );

      final Map<String, dynamic> responseData = jsonDecode(response.body);

      if (response.statusCode == 201) {
        print(
          "✅ [SERVICE] Application recorded with ID: ${responseData['applicationId']}",
        );
        return {'success': true, 'message': responseData['message']};
      } else {
        print(
          "❌ [SERVICE] Application rejected by server: ${responseData['message']}",
        );
        return {
          'success': false,
          'message': responseData['message'] ?? 'Submission failed.',
        };
      }
    } catch (e) {
      print("💥 [SERVICE CRASH] Network request failure: $e");
      return {
        'success': false,
        'message': 'Network error. Please confirm your server is running.',
      };
    }
  }
}
