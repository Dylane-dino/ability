import 'dart:convert';

class JobListing {
  final int? jobId;
  final int?
  companyId; // 🚀 FIX: Changed to nullable int? to match the frontend post layout
  final String? companyName;
  final String title;
  final String description;
  final String jobType;
  final bool isRemote;
  final Map<String, dynamic>? accommodations;
  final int? applicantCount;

  JobListing({
    this.jobId,
    this.companyId, // 🚀 FIX: Removed 'required' constraint so it can be omitted
    this.companyName,
    required this.title,
    required this.description,
    required this.jobType,
    required this.isRemote,
    this.accommodations,
    this.applicantCount,
  });

  // THE ADAPTER METHOD
  // Maps unpredictable backend database schemas smoothly into our class model.
  factory JobListing.fromMapAdapter(Map<String, dynamic> json) {
    // Bulletproof decoding logic for accommodations
    Map<String, dynamic>? parsedAccommodations;

    // Look for both key aliases coming from your backend SELECT statement SQL alias
    var accommodationsData =
        json['accommodations'] ?? json['accommodation_offerings'];

    if (accommodationsData != null) {
      if (accommodationsData is Map) {
        // Case A: Arrives pre-parsed as a JSON Map object structure
        parsedAccommodations = Map<String, dynamic>.from(accommodationsData);
      } else if (accommodationsData is String) {
        // Case B: Arrives as an unparsed raw text JSON String representation
        try {
          parsedAccommodations = Map<String, dynamic>.from(
            jsonDecode(accommodationsData),
          );
        } catch (e) {
          print("Error parsing string accommodations value: $e");
        }
      }
    }

    return JobListing(
      jobId: json['job_id'] as int?,
      companyId:
          json['company_id'] as int? ??
          json['employer_id'] as int? ??
          0, // Handles fallback if backend uses employer_id alias
      companyName: json['company_name'] ?? 'Unknown Company',
      title: json['title'] as String? ?? 'No Title',
      description: json['description'] as String? ?? '',
      jobType: json['job_type'] as String? ?? 'Full-time',

      // Translates safe MySQL integer configurations cleanly back to runtime booleans
      isRemote: json['is_remote'] == 1 || json['is_remote'] == true,

      accommodations: parsedAccommodations,

      // Map the backend key for applicant counts safely (defaults to 0 if not provided)
      applicantCount:
          json['applicantCount'] as int? ??
          json['applicant_count'] as int? ??
          0,
    );
  }

  // Keeps your existing code working perfectly by routing .fromJson to our adapter!
  factory JobListing.fromJson(Map<String, dynamic> json) {
    return JobListing.fromMapAdapter(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'company_id': companyId,
      'title': title,
      'description': description,
      'job_type': jobType,
      'is_remote': isRemote,
      'accommodation_offerings': accommodations,
      'applicant_count': applicantCount, // Kept for object consistency
    };
  }
}
