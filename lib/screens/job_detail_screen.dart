// lib/screens/job_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../app_components.dart';
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
  bool _hasApplied = false;
  String? _error;
  late int _jobId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Get jobId from route arguments
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

      // Check if current seeker has already applied
      final prefs = await SharedPreferences.getInstance();
      final seekerId = prefs.getInt('userId');
      if (seekerId != null) {
        final applications = await ApplicationService().getSeekerApplications(
          seekerId,
        );
        final hasApplied = applications.any((a) => a.jobId == _jobId);
        setState(() => _hasApplied = hasApplied);
      }

      setState(() {
        _job = job;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _handleApply() async {
    final prefs = await SharedPreferences.getInstance();
    final seekerId = prefs.getInt('userId');
    if (seekerId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please log in to apply.')));
      return;
    }

    // Navigate to Apply Job Screen
    final result = await Navigator.pushNamed(
      context,
      '/apply-job',
      arguments: {
        'jobId': _jobId,
        'jobTitle': _job?.title,
        'companyName': _job?.companyName,
      },
    );

    if (result == true) {
      _fetchJobAndApplicationStatus(); // Refresh applied status
    }
  }

  Future<void> _openChatWithEmployer() async {
    if (_job == null) return;

    final adminData = await CompanyService().getCompanyAdmin(_job!.companyId);
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
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
                    "${job.companyName} • ${job.isRemote ? 'Remote' : 'On-Site'}",
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
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
                            backgroundColor: Colors.blueAccent,
                          ),
                        if (job.accommodations!['screen_reader'] == true)
                          Chip(
                            label: const Text("Screen Reader Support"),
                            backgroundColor: Colors.blueAccent,
                          ),
                        if (job.accommodations!['flexible_hours'] == true)
                          Chip(
                            label: const Text("Flexible Hours"),
                            backgroundColor: Colors.blueAccent,
                          ),
                        if (job.accommodations!['remote'] == true)
                          Chip(
                            label: const Text("Remote Work"),
                            backgroundColor: Colors.blueAccent,
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
                  Text(job.description),
                  const SizedBox(height: 40),
                  if (_hasApplied)
                    ElevatedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check_circle),
                      label: const Text(
                        "Applied",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      onPressed: _handleApply,
                      icon: const Icon(Icons.send),
                      label: const Text(
                        "Apply Now",
                        style: TextStyle(fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 32,
                        ),
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: _job != null
                        ? () => _openChatWithEmployer()
                        : null,
                    icon: const Icon(Icons.chat),
                    label: const Text("Message Recruiter"),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 32,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
