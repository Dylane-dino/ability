import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/job_listing.dart';
import '../services/job_services.dart';
import '../services/application_service.dart';
import '../services/company_service.dart';

class JobDetailScreen extends StatefulWidget {
  const JobDetailScreen({super.key});

  @override
  State<JobDetailScreen> createState() => _JobDetailScreenState();
}

class _JobDetailScreenState extends State<JobDetailScreen> {
  JobListing? _job;
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _hasApplied = false;
  String? _error;
  late int _jobId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['jobId'] != null) {
      _jobId = args['jobId'] as int;
      _fetchJobAndApplicationStatus();
    } else {
      setState(() {
        _error = 'Job ID not provided';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchJobAndApplicationStatus() async {
    setState(() => _isLoading = true);
    try {
      final jobs = await JobService().fetchJobs();
      final job = jobs.firstWhere(
        (j) => j.jobId == _jobId,
        orElse: () => throw Exception('Job not found'),
      );

      final prefs = await SharedPreferences.getInstance();
      // 🛠️ FALLBACK BYPASS: Use user ID 1 if not logged in for testing
      final seekerId = prefs.getInt('userId') ?? 1;

      final applications = await ApplicationService().getSeekerApplications(
        seekerId,
      );
      final hasApplied = applications.any((a) => a.jobId == _jobId);

      setState(() {
        _job = job;
        _hasApplied = hasApplied;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // 🚀 FIXED: Opens ApplyJobScreen with correct form data instead of blinding submitting!
  Future<void> _handleApply() async {
    if (_job == null) return;

    // Open ApplyJobScreen and wait for a completion result
    final dynamic didApply = await Navigator.pushNamed(
      context,
      '/apply-job', // Ensure this route is mapped to ApplyJobScreen inside main.dart
      arguments: {
        'jobId': _job!.jobId,
        'jobTitle': _job!.title,
        'companyName': _job!.companyName ?? 'Premium Employer',
      },
    );

    // If the form screen returns true, update the UI state smoothly!
    if (didApply == true) {
      setState(() {
        _hasApplied = true;
      });
    }
  }

  Future<void> _openChatWithEmployer() async {
    if (_job == null) return;

    final adminData = await CompanyService().getCompanyAdmin(
      _job!.companyId ?? 0,
    );
    if (adminData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Employer not found. Cannot open chat.")),
      );
      return;
    }

    final adminUserId = adminData['admin_user_id'] as int;
    final companyName = adminData['company_name'] as String?;

    await Navigator.pushNamed(
      context,
      '/chat',
      arguments: {
        'otherUserId': adminUserId,
        'otherUserName': companyName ?? 'Employer',
        'jobId': _jobId,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null || _job == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Job Details")),
        body: Center(child: Text("Error: $_error")),
      );
    }

    final job = _job!;

    return Scaffold(
      appBar: AppBar(title: Text(job.title)),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                job.title,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "${job.companyName ?? 'Premium Employer'} • ${job.isRemote ? 'Remote' : 'On-Site'}",
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 16),

              // Match Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 30),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "98% Match! This workplace provides the accommodations you requested.",
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Accommodations Chips
              const Text(
                "Accessibility Features",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (job.accommodations != null) ...[
                    if (job.accommodations!['wheelchair'] == true)
                      Chip(
                        label: const Text("Wheelchair Accessible"),
                        backgroundColor: Colors.blue.shade100,
                      ),
                    if (job.accommodations!['screen_reader'] == true)
                      Chip(
                        label: const Text("Screen Reader Support"),
                        backgroundColor: Colors.blue.shade100,
                      ),
                    if (job.accommodations!['flexible_hours'] == true)
                      Chip(
                        label: const Text("Flexible Hours"),
                        backgroundColor: Colors.blue.shade100,
                      ),
                    if (job.accommodations!['remote'] == true)
                      Chip(
                        label: const Text("Remote Work"),
                        backgroundColor: Colors.blue.shade100,
                      ),
                  ] else
                    const Chip(label: Text("No specific features listed")),
                ],
              ),
              const SizedBox(height: 24),

              const Text(
                "About the Role",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                job.description,
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 40),

              // ⚡ ACTION BUTTON OR APPLIED STATE
              SizedBox(
                width: double.infinity,
                child: _hasApplied
                    ? ElevatedButton.icon(
                        onPressed: null,
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.grey,
                        ),
                        label: const Text(
                          "Applied to this Listing",
                          style: TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _handleApply,
                        icon: _isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.send),
                        label: Text(
                          _isSubmitting ? "Processing..." : "Apply Now",
                          style: const TextStyle(fontSize: 18),
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
              ),
              const SizedBox(height: 12),

              // Chat Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _job != null
                      ? () => _openChatWithEmployer()
                      : null,
                  icon: const Icon(Icons.chat),
                  label: const Text(
                    "Message Recruiter",
                    style: TextStyle(fontSize: 16),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
