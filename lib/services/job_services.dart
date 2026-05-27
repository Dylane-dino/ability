// lib/services/job_services.dart
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/job_listing.dart';

class JobService {
  static const String _jobsBaseUrl = 'http://192.168.88.176:3000/api/jobs';

  // --- FETCH ALL JOBS (For Seeker Dashboard) ---
  Future<List<JobListing>> fetchJobs() async {
    try {
      final response = await http.get(Uri.parse(_jobsBaseUrl));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => JobListing.fromJson(json)).toList();
      } else {
        throw Exception("Failed to load jobs");
      }
    } catch (e) {
      print("Error fetching jobs: $e");
      return [];
    }
  }

  // --- POST A NEW JOB (For Employer Dashboard) ---
  Future<bool> postJob(JobListing job) async {
    try {
      final response = await http.post(
        Uri.parse(_jobsBaseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'company_id': job.companyId,
          'title': job.title,
          'description': job.description,
          'job_type': job.jobType,
          'is_remote': job.isRemote,
          'accommodation_offerings': job.accommodations,
        }),
      );

      return response.statusCode == 201; // 201 means "Created successfully"
    } catch (e) {
      print("Error posting job: $e");
      return false;
    }
  }
}
